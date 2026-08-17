#!/usr/bin/env python3.11
"""Regenerate the core_c1d LEF abstract from the real cell GDS.

Two defects in the shipped core_c1d.lef make KLayout signoff DRC fail on any
routed design, while Innovus reports zero violations because it cannot see the
geometry involved.

1. Pins are declared on metal1 only.

   309 of the 310 signal pins already contain a via1 AND a metal2 pad inside
   the cell -- every pin is brought up to metal2 by the cell itself, and the
   pad is a 2.5x2.5um square, exactly VIA12's metal enclosure. Because the LEF
   only advertises metal1, Innovus lands its own via1 on the pin, stacked about
   0.05um off the cell's existing via. Those two cuts merge into a stepped
   polygon with 0.05um and 1.55um edges, which is what rule 9.1.1 ("exact via
   width = 1.5um") reports. The same router vias sit over cell poly and
   contacts, producing 9.4.1 and 9.3.1 violations.

   The vendor already did this correctly for exactly one pin (NND801 IN8),
   which confirms the intent. This script declares the metal2 port for the rest,
   taking the geometry from the GDS and only where a via1 electrically ties the
   pad to that pin's metal1 (never to VDD/VSS).

2. metal2 and via1 obstructions are missing for most macros.

   66 macros contain metal2 and via1 shapes; only 30 and 27 respectively declare
   OBS for them. The router treats that geometry as free space, so after the cell
   GDS is merged in at streamOut it collides with it (10.1.1 metal2 spacing).

Obstructions are emitted as the exact cell geometry, NOT grown by the design
rule. Innovus applies the tech LEF spacing (metal1 1.5, metal2 1.7, via1 1.5)
between routing and a blockage on its own; pre-growing them double-counts and
over-constrains the router. The via1 obstruction is the exception -- it adds
poly/contact/diffusion halos, because those rules constrain a via cut against
layers that do not exist in the LEF at all:

  metal1 OBS : cell metal1 minus pin metal1 ports
  metal2 OBS : cell metal2 minus pin metal2 ports
  via1   OBS : cell vias
               U poly    + 1.2um   (9.4.1)
               U contact + 1.5um   (9.3.1)
               U a 1.5um band along every diffusion edge (GUIDELINE-6)

That via1 obstruction covers ~58% of a cell, and no pin has a legal via site
inside it -- which is exactly why the metal2 ports matter. With them the router
reaches every pin without a via and only changes layer out in the row channels,
where none of these rules apply.

All emitted geometry is snapped onto the 0.005um MANUFACTURINGGRID -- obstructions
outward, pin ports inward. Innovus rejects off-grid LEF shapes with IMPLF-82, and
Region.sized() lands on the 1nm grid at non-convex corners.

Usage: gen_signoff_lef.py <in.lef> <in.gds> <out.lef>
"""
import math
import re
import sys
import collections
import klayout.db as db

IN_LEF, IN_GDS, OUT_LEF = sys.argv[1], sys.argv[2], sys.argv[3]

VIA_POLY_SEP = 1.2      # rule 9.4.1
VIA_CONT_SEP = 1.5      # rule 9.3.1
VIA_SIZE = 1.5          # rule 9.1.1, used for the GUIDELINE-6 diffusion band
POWER_PINS = ("VDD", "VSS")

ly = db.Layout()
ly.read(IN_GDS)
dbu = ly.dbu
U = lambda v: int(round(v / dbu))
GRID = U(0.005)
LY = {n: ly.layer(l, 0) for n, l in
      {"diff": 2, "poly": 4, "contact": 7, "metal1": 8, "via1": 9,
       "metal2": 10}.items()}

src = open(IN_LEF).read()


def snap_out(b):
    return db.Box(int(math.floor(b.left / GRID)) * GRID,
                  int(math.floor(b.bottom / GRID)) * GRID,
                  int(math.ceil(b.right / GRID)) * GRID,
                  int(math.ceil(b.top / GRID)) * GRID)


def snap_in(b):
    nb = db.Box(int(math.ceil(b.left / GRID)) * GRID,
                int(math.ceil(b.bottom / GRID)) * GRID,
                int(math.floor(b.right / GRID)) * GRID,
                int(math.floor(b.top / GRID)) * GRID)
    return nb if nb.width() > 0 and nb.height() > 0 else None


def rects_split(region):
    """Rectilinear region -> list of boxes, via a scanline on y."""
    reg = region.merged()
    if reg.is_empty():
        return []
    ys = set()
    for p in reg.each():
        for e in p.each_edge():
            ys.add(e.p1.y)
            ys.add(e.p2.y)
    ys = sorted(ys)
    bb = reg.bbox()
    out = []
    for y0, y1 in zip(ys, ys[1:]):
        if y1 <= y0:
            continue
        strip = reg & db.Region(db.Box(bb.left, y0, bb.right, y1))
        for p in strip.merged().each():
            pb = p.bbox()
            out.append(db.Box(pb.left, y0, pb.right, y1))
    out.sort(key=lambda b: (b.left, b.right, b.bottom))
    merged = []
    for b in out:
        prev = merged[-1] if merged else None
        if prev and prev.left == b.left and prev.right == b.right \
                and prev.top == b.bottom:
            merged[-1] = db.Box(b.left, prev.bottom, b.right, b.top)
        else:
            merged.append(b)
    return merged


def emit(region, layer, indent):
    """LAYER + RECT lines for an obstruction, snapped outward onto the grid."""
    snapped = db.Region([snap_out(b) for b in rects_split(region)]).merged()
    lines = [f"{indent}LAYER {layer} ;"]
    for b in rects_split(snapped):
        lines.append("%s  RECT %.3f %.3f %.3f %.3f ;" % (
            indent, b.left * dbu, b.bottom * dbu, b.right * dbu, b.top * dbu))
    return lines


def parse_pins(body):
    """[(pin_name, pin_body, {layer: Region})] in declaration order."""
    pins = []
    for pn, pb in re.findall(r'PIN\s+(\S+)(.*?)END\s+\1(?=\s|$)', body, re.S):
        ports = collections.defaultdict(db.Region)
        cur = None
        for line in pb.splitlines():
            s = line.strip()
            m = re.match(r'LAYER\s+(\S+)\s*;', s)
            if m:
                cur = m.group(1)
                continue
            m = re.match(r'RECT\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)'
                         r'\s+(-?[\d.]+)\s*;', s)
            if m and cur:
                v = [float(x) for x in m.groups()]
                ports[cur].insert(db.Box(U(v[0]), U(v[1]), U(v[2]), U(v[3])))
        pins.append((pn, pb, {k: v.merged() for k, v in ports.items()}))
    return pins


stats = collections.Counter()
coverage = []
leaks = []


def rebuild(name, body):
    cell = ly.cell(name)
    if cell is None:
        return None
    R = lambda k: db.Region(cell.begin_shapes_rec(LY[k])).merged()
    m1, m2, vias = R("metal1"), R("metal2"), R("via1")
    poly, cont, diff = R("poly"), R("contact"), R("diff")

    pins = parse_pins(body)
    by_name = {pn: ports for pn, _, ports in pins}

    # metal2 pads that are electrically power, so a signal pin never claims one
    power_m1 = db.Region()
    for pn in POWER_PINS:
        power_m1 += by_name.get(pn, {}).get("metal1", db.Region())
    m2_power = m2.interacting(vias.interacting(power_m1.merged()))

    # metal2 pad per signal pin, reached through a via1 sitting on its metal1
    pin_m2 = {}
    for pn, _, ports in pins:
        if pn in POWER_PINS:
            continue
        pm1 = ports.get("metal1", db.Region())
        if pm1.is_empty():
            continue
        pad = m2.interacting(vias.interacting(pm1))
        if pad.is_empty():
            stats["pin_no_m2_pad"] += 1
            continue
        if not (pad & m2_power).is_empty():
            stats["pin_m2_pad_shared_with_power"] += 1
            continue
        pin_m2[pn] = pad.merged()
        stats["pin_m2_port_added"] += 1

    # Power rails and straps are under-declared by several macros. FILLER2 says
    # PIN VSS = (0,0)-(4,5) while its metal1 really runs to y=9; VDDCON and
    # VSSCON do the same; INVR04 has a 2.5x10.5um metal2 VDD strap that the LEF
    # never mentions at all. Such metal must be *declared as the power pin*, not
    # merely dropped:
    #   - leaving it as an obstruction makes every VDD/VSS special wire short
    #     against it (1000+ "Special Wire of Net VSS & Blockage of Cell FILL_*")
    #   - dropping it entirely makes it invisible, and signal routing then comes
    #     closer than 1.7um to it (this is what the last 10 10.1.1 violations
    #     were: all of them at INVR04's undeclared VDD strap)
    # Declaring it as the pin gets both right, since Innovus keeps other nets
    # away from pin geometry while letting the power router connect to it.
    # Other pins' declared geometry is carved out, so claiming the whole
    # connected shape never swallows another pin. VDDCON's TIEHI sits on the
    # same physical metal as VDD, and declaring both would assert a pin short.
    other_m1 = db.Region()
    other_m2 = db.Region()
    for pn, _, ports in pins:
        if pn in POWER_PINS:
            continue
        other_m1 += ports.get("metal1", db.Region())
        other_m2 += ports.get("metal2", db.Region())
    for pad in pin_m2.values():
        other_m2 += pad

    power_port = {}
    for pn in POWER_PINS:
        decl = by_name.get(pn, {}).get("metal1", db.Region())
        if decl.is_empty():
            continue
        shapes_m1 = m1.interacting(decl) - other_m1.merged()
        shapes_m2 = m2.interacting(vias.interacting(m1.interacting(decl))) \
            - other_m2.merged()
        power_port[pn] = {"metal1": shapes_m1.merged(),
                          "metal2": shapes_m2.merged()}

    # Every piece of cell metal is now either a declared port or an obstruction.
    declared_m1 = db.Region()
    declared_m2 = db.Region()
    for pn, _, ports in pins:
        if pn in POWER_PINS:
            continue
        declared_m1 += ports.get("metal1", db.Region())
        declared_m2 += ports.get("metal2", db.Region())
    for pad in pin_m2.values():
        declared_m2 += pad
    for pp in power_port.values():
        declared_m1 += pp["metal1"]
        declared_m2 += pp["metal2"]

    snap_reg = lambda r: db.Region([snap_out(b) for b in rects_split(r)]).merged()
    declared_m1 = snap_reg(declared_m1)
    declared_m2 = snap_reg(declared_m2)
    m1_obs = m1 - declared_m1
    m2_obs = m2 - declared_m2

    # self-check: nothing may be left undeclared and unobstructed
    for lname, geo, dec, obs in (("metal1", m1, declared_m1, m1_obs),
                                 ("metal2", m2, declared_m2, m2_obs)):
        leak = (geo - dec.merged() - obs).merged()
        if not leak.is_empty():
            stats[f"LEAK_{lname}"] += 1
            leaks.append((name, lname, leak.area() * dbu * dbu))
    diff_band = (diff.sized(U(VIA_SIZE)) - diff.sized(-U(VIA_SIZE))).merged()
    via_obs = (vias + poly.sized(U(VIA_POLY_SEP)) +
               cont.sized(U(VIA_CONT_SEP)) + diff_band).merged()
    via_obs = (via_obs & db.Region(cell.dbbox().to_itype(dbu))).merged()

    ca = cell.dbbox().area()
    if ca:
        coverage.append((name, 100.0 * via_obs.area() * dbu * dbu / ca))

    # ---- rewrite the body: extend ports, snap pin rects, replace OBS ----
    def port_rects(region, layer):
        # snapped OUTWARD: an inward snap leaves a sub-grid sliver of real metal
        # that is neither port nor obstruction, i.e. invisible to the router.
        # Growing a port by <=4nm is harmless -- different-net metal is at least
        # 1.5um away -- and keeps coverage complete.
        rows = []
        for b in rects_split(region):
            nb = snap_out(b)
            if nb is None:
                continue
            rows.append("        RECT %.3f %.3f %.3f %.3f ;" % (
                nb.left * dbu, nb.bottom * dbu, nb.right * dbu, nb.top * dbu))
        return (["      LAYER %s ;" % layer] + rows) if rows else []

    def rewrite_pin(m):
        pn, pb = m.group(1), m.group(2)
        add = []
        if pn in power_port:
            # replace the under-declared rail/strap with the real geometry
            add += port_rects(power_port[pn]["metal1"], "metal1")
            add += port_rects(power_port[pn]["metal2"], "metal2")
            if add:
                stats["power_port_rewritten"] += 1
                head = pb[:pb.find("PORT")] if "PORT" in pb else pb
                return (f"PIN {pn}" + head + "PORT\n" + "\n".join(add)
                        + "\n    END\n  " + f"END {pn}")
            return m.group(0)
        if pn in pin_m2:
            add = port_rects(pin_m2[pn], "metal2")
            if not add:
                stats["pin_m2_pad_unusable"] += 1
                return m.group(0)
            end = pb.rstrip().rfind("END")
            if end < 0:
                return m.group(0)
            stats["pin_m2_port_emitted"] += 1
            block = "\n".join(add) + "\n    "
            return (f"PIN {pn}" + pb[:end] + block + pb[end:].lstrip()
                    + f"END {pn}")
        return m.group(0)

    # match each PIN block by name so identical pin bodies cannot be confused
    new_body = re.sub(r'PIN\s+(\S+)(.*?)END\s+\1(?=\s|$)', rewrite_pin, body,
                      flags=re.S)
    new_body = re.sub(r'\n\s*OBS\b.*?\n\s*END\s*\n', '\n', new_body, flags=re.S)
    new_body = snap_pin_rects(new_body)

    chunks = []
    for lname, reg in (("metal1", m1_obs), ("metal2", m2_obs),
                       ("via1", via_obs)):
        if not reg.is_empty():
            chunks += emit(reg, lname, "    ")
    obs = ("  OBS\n" + "\n".join(chunks) + "\n  END\n") if chunks else ""
    return new_body.rstrip("\n ") + "\n" + obs


def snap_pin_rects(text):
    def repl(m):
        v = [float(x) for x in m.groups()]
        b = db.Box(U(v[0]), U(v[1]), U(v[2]), U(v[3]))
        if all(c % GRID == 0 for c in (b.left, b.bottom, b.right, b.top)):
            return m.group(0)
        nb = snap_in(b)
        if nb is None:
            return m.group(0)
        stats["pin_rect_snapped"] += 1
        return "RECT %.3f %.3f %.3f %.3f ;" % (
            nb.left * dbu, nb.bottom * dbu, nb.right * dbu, nb.top * dbu)
    return re.sub(r'RECT\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)'
                  r'\s+(-?[\d.]+)\s*;', repl, text)


out = []
pos = 0
for m in re.finditer(r'(MACRO\s+(\S+))(.*?)(END\s+\2(?=\s|$))', src, re.S):
    head, name, body, tail = m.group(1), m.group(2), m.group(3), m.group(4)
    new_body = rebuild(name, body)
    if new_body is None:
        continue
    out.append(src[pos:m.start()])
    out.append(head + new_body + tail)
    pos = m.end()
    stats["macros"] += 1
out.append(src[pos:])
open(OUT_LEF, "w").write("".join(out))

print(f"wrote {OUT_LEF}")
for k in ("macros", "pin_m2_port_added", "pin_m2_port_emitted",
          "power_port_rewritten", "LEAK_metal1", "LEAK_metal2",
          "pin_m2_pad_unusable", "pin_no_m2_pad",
          "pin_m2_pad_shared_with_power", "pin_rect_snapped"):
    print(f"  {k}: {stats[k]}")
if leaks:
    print("  UNDECLARED GEOMETRY (must be empty):")
    for n, l, a in leaks[:10]:
        print(f"    {n} {l} {a:.3f} um2")
if coverage:
    print("  mean via1 OBS coverage: %.1f%% of cell area"
          % (sum(c for _, c in coverage) / len(coverage)))
