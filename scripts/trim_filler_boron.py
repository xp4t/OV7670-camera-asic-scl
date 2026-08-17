#!/usr/bin/env python3.11
"""Trim the filler cells' boron overhang to the cell boundary.

FILLER1..5 draw boron (and boron_rev) 0.2um wider than their LEF SIZE -- e.g.
FILLER2 is 4.0um wide but its boron spans 0..4.2um. The overhang exists so that
abutting fillers overlap rather than merely touch, but it also reaches 0.2um into
whatever cell sits to the right.

That is a problem because 1580 of the placed instances have N+ diffusion within
0.9um of a cell edge, and rule 5.5.1 wants boron at least 0.7um from Ndiff. Where
that diffusion is an nwell tap sitting in the filler's boron band, the overhang
closes the gap to 0.55-0.65um. Measured on the v9 layout: FILLER2 at x=769.4-773.4
puts boron out to 773.6, while NND201's tap starts at 774.25 -- 0.65um, and 33
violations of exactly that shape.

Trimming the overhang to zero leaves filler boron abutting its neighbour's boron
edge-to-edge, which still merges into one implant strip (so 5.7.1 spacing and
5.1.1 width are unaffected), while giving back the cell's own 0.75um clearance to
its tap. boron_rev is trimmed identically, since rule 6.1.1 requires the two to
overlap exactly.

Usage: trim_filler_boron.py <in.gds> <in.lef> <out.gds>
"""
import re
import sys
import klayout.db as db

IN_GDS, IN_LEF, OUT_GDS = sys.argv[1], sys.argv[2], sys.argv[3]

BORON = 5          # P+ implant
BORON_REV = 6      # reversal of the same mask, rule 6.1.1
FILLERS = ("FILLER1", "FILLER2", "FILLER3", "FILLER4", "FILLER5")

size = {}
for name, body in re.findall(r'MACRO\s+(\S+)(.*?)END\s+\1(?=\s|$)',
                             open(IN_LEF).read(), re.S):
    m = re.search(r'SIZE\s+([\d.]+)\s+BY\s+([\d.]+)', body)
    if m:
        size[name] = (float(m.group(1)), float(m.group(2)))

ly = db.Layout()
ly.read(IN_GDS)
dbu = ly.dbu
U = lambda v: int(round(v / dbu))

trimmed = 0
for name in FILLERS:
    cell = ly.cell(name)
    if cell is None or name not in size:
        print(f"  {name}: not present, skipped")
        continue
    w, h = size[name]
    outline = db.Region(db.Box(0, 0, U(w), U(h)))
    for layer in (BORON, BORON_REV):
        li = ly.layer(layer, 0)
        before = db.Region(cell.shapes(li)).merged()
        if before.is_empty():
            continue
        after = (before & outline).merged()
        if after == before:
            continue
        cell.shapes(li).clear()
        for poly in after.each():
            cell.shapes(li).insert(poly)
        print(f"  {name} layer {layer}/0: "
              f"{before.bbox().to_dtype(dbu)} -> {after.bbox().to_dtype(dbu)}")
        trimmed += 1

ly.write(OUT_GDS)
print(f"trimmed {trimmed} layer(s) -> {OUT_GDS}")
