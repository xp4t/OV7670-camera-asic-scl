#!/usr/bin/env python3.11
"""Flatten a gate-level Verilog netlist into SPICE for KLayout LVS.

KLayout's `schematic()` reads SPICE only -- handing it a .v makes it parse the
file as SPICE and die on the first line ("'M' element must have four nodes").
So the schematic side has to be converted.

Port ORDER matters: SPICE subcircuit calls are positional, so every `X` line must
list nets in the same order as the corresponding `.subckt` in the foundry CDL.
This derives blackbox module declarations straight from that CDL, so yosys emits
the right order by construction, then flattens the hierarchy and writes SPICE.

Usage: gen_lvs_spice.py <netlist.v> <core_iolib.cdl> <out.spi> [top]
"""
import re
import subprocess
import sys
import tempfile
import os

NETLIST, CDL, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
TOP = sys.argv[4] if len(sys.argv) > 4 else "top"
YOSYS = os.environ.get("YOSYS", "/home/rithwik/klayout_cf/yosys/bin/yosys")

subckts = []
for m in re.finditer(r'^\.subckt\s+(\S+)((?:[^\n]|\n\+)*)', open(CDL).read(),
                     re.M | re.I):
    name = m.group(1)
    pins = m.group(2).replace("\n+", " ").split()
    if pins:
        subckts.append((name, pins))
if not subckts:
    sys.exit(f"ERROR: no .subckt definitions found in {CDL}")

lines = ["// blackbox cell declarations, port order taken from the foundry CDL",
         "// so that yosys' write_spice emits positionally-correct X lines"]
for name, pins in subckts:
    lines.append(f"(* blackbox *)")
    lines.append(f"module {name}({', '.join(pins)});")
    lines.append(f"  inout {', '.join(pins)};")
    lines.append("endmodule")
blackbox = "\n".join(lines) + "\n"

with tempfile.TemporaryDirectory() as td:
    bb = os.path.join(td, "blackbox.v")
    open(bb, "w").write(blackbox)
    script = "\n".join([
        f"read_verilog -lib {bb}",
        f"read_verilog {NETLIST}",
        f"hierarchy -top {TOP}",
        "flatten",
        f"write_spice -neg 0 -pos 1 {OUT}",
    ])
    sf = os.path.join(td, "run.ys")
    open(sf, "w").write(script)
    print(f"blackbox cells declared: {len(subckts)}")
    r = subprocess.run([YOSYS, "-q", "-s", sf], capture_output=True, text=True)
    if r.returncode != 0:
        sys.stderr.write(r.stdout[-4000:] + r.stderr[-4000:])
        sys.exit(f"ERROR: yosys failed ({r.returncode})")
    for line in (r.stdout + r.stderr).splitlines():
        if re.search(r'Warning|ERROR', line):
            print("  " + line)

# ---------------------------------------------------------------------------
# Two post-processing passes, both needed for KLayout's SPICE reader.
#
# 1. Net aliases. yosys encodes Verilog `assign` (including ties to 1'b0/1'b1)
#    as zero-volt sources, "V<n> netA netB DC 0". KLayout rejects 'V' as an
#    unknown element type. They are not really sources -- they say the two nets
#    are one net -- so resolve them with union-find and drop the lines.
#    Canonical name preference: VDD/VSS, then a top-level port, then internal;
#    a port tied to a constant really is on the VDD/VSS net in the layout.
#
# 2. Power pins. A gate-level netlist carries no VDD/VSS connections (Innovus
#    makes them with globalNetConnect), so yosys leaves those pins on unique
#    _NC nets. Reconnect them positionally using each cell's CDL pin order.
# ---------------------------------------------------------------------------
lines = open(OUT).read().splitlines(keepends=True)

ports = set()
for line in lines:
    if line.upper().startswith(".SUBCKT"):
        ports.update(line.split()[2:])
        break

CONST = {"0": "VSS", "1": "VDD"}
parent = {}
def find(x):
    parent.setdefault(x, x)
    while parent[x] != x:
        parent[x] = parent[parent[x]]
        x = parent[x]
    return x
def rank(n):
    if n in ("VDD", "VSS"):
        return 3
    if n in ports:
        return 2
    return 1
def union(a, b):
    ra, rb = find(a), find(b)
    if ra == rb:
        return
    if rank(ra) < rank(rb):
        ra, rb = rb, ra
    parent[rb] = ra

aliases = 0
for line in lines:
    if line[:1] in ("V", "v") and " DC " in line:
        f = line.split()
        if len(f) >= 3:
            union(CONST.get(f[1], f[1]), CONST.get(f[2], f[2]))
            aliases += 1

POWER = {"VDD": "VDD", "VSS": "VSS", "vdd": "VDD", "vss": "VSS"}
pin_index = {}
for name, pins in subckts:
    idx = {i: POWER[p] for i, p in enumerate(pins) if p in POWER}
    if idx:
        pin_index[name] = idx

def canon(n):
    return find(CONST.get(n, n))

fixed = 0
out_lines = []
for line in lines:
    if line[:1] in ("V", "v") and " DC " in line:
        continue                       # alias resolved into the net names
    if line[:1] in ("X", "x"):
        parts = line.split()
        cell = parts[-1]
        nets = [canon(n) for n in parts[1:-1]]
        for i, net in pin_index.get(cell, {}).items():
            if i < len(nets) and nets[i].startswith("_NC"):
                nets[i] = net
                fixed += 1
        line = " ".join([parts[0]] + nets + [cell]) + "\n"
    elif line.upper().startswith(".SUBCKT"):
        f = line.split()
        line = " ".join(f[:2] + [canon(n) for n in f[2:]]) + "\n"
    out_lines.append(line)
open(OUT, "w").writelines(out_lines)

# ---------------------------------------------------------------------------
# 3. Wrap in .SUBCKT/.ENDS. write_spice emits the *top* module's contents flat
#    (only non-top modules become subcircuits), so without this KLayout reports
#    "Can't find a schematic counterpart for the top cell". Port bits use
#    yosys' dot form, e.g. o_bram_addra.0.
# ---------------------------------------------------------------------------
vsrc = open(NETLIST).read()
mt = re.search(r'\bmodule\s+' + re.escape(TOP) + r'\s*\((.*?)\);', vsrc, re.S)
if not mt:
    sys.exit(f"ERROR: no 'module {TOP}' found in {NETLIST}")
decl_ports = [x.strip() for x in mt.group(1).replace("\n", " ").split(",") if x.strip()]

body = vsrc[mt.end():]
width = {}
for kind, rng, names in re.findall(
        r'\b(input|output|inout)\b\s*(?:wire|reg)?\s*(\[[^\]]*\])?\s*([^;]+);', body):
    for nm in (n.strip() for n in names.split(",")):
        if nm in decl_ports:
            width[nm] = rng.strip()

port_nets = []
for nm in decl_ports:
    rng = width.get(nm, "")
    m = re.match(r'\[\s*(\d+)\s*:\s*(\d+)\s*\]', rng) if rng else None
    if m:
        hi, lo = int(m.group(1)), int(m.group(2))
        step = -1 if hi >= lo else 1
        for b in range(hi, lo + step, step):
            port_nets.append(f"{nm}.{b}")
    else:
        port_nets.append(nm)

seen, ports_final = set(), []
for n in (canon(x) for x in port_nets):
    if n not in seen:          # a port tied to a constant lands on VDD/VSS
        seen.add(n)
        ports_final.append(n)

hdr = [l for l in out_lines if l.startswith("*")][:1]
rest = [l for l in out_lines if not l.startswith("*")]
out_lines = hdr + [f".SUBCKT {TOP} " + " ".join(ports_final) + "\n"] + rest + [".ENDS\n"]
open(OUT, "w").writelines(out_lines)
print(f"top ports declared: {len(decl_ports)} -> {len(port_nets)} bits -> "
      f"{len(ports_final)} unique nets")

n = sum(1 for l in out_lines if l.startswith(("X", "x")))
left = sum(l.count("_NC") for l in out_lines)
print(f"wrote {OUT}: {n} subcircuit instances")
print(f"net aliases resolved (V elements removed): {aliases}")
print(f"power pins reconnected to VDD/VSS: {fixed}")
print(f"remaining _NC references: {left}")
