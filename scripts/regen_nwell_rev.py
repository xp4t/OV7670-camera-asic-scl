#!/usr/bin/env python3.11
"""Regenerate the nwell_rev mask (layer 3) from the final merged nwell.

nwell_rev is a derived mask, not drawn geometry. The design rule document
(LEVEL 3) defines it as "reversal of N-Well mask (Level 1) with 2um oversize
each side", and rule 3.1.1 checks exactly that:

    ovnwell = nwell.sized(2.um)
    (ovnwell ^ nwell_rev).output("3.1.1 : Shapes present in Nwell_rev XOR Nwell")

Each cell ships its own pre-oversized nwell_rev, and per cell those are correct.
But oversizing is not distributive over union: sizing the *merged* nwell rounds a
step differently from unioning the individually-sized pieces. Where two abutting
cells' nwells differ by a small step, the two constructions disagree over a
sliver exactly as wide as the oversize. Measured on this design: 2 slivers of
exactly 2.000 x 0.100um.

Rebuilding the layer from the finished nwell makes 3.1.1 exact by construction,
and matches how the mask is actually defined. nwell_rev is referenced nowhere
else in the deck, so nothing else is affected.

Usage: regen_nwell_rev.py <in.gds> <out.gds> [top_cell]
"""
import sys
import klayout.db as db

IN_GDS, OUT_GDS = sys.argv[1], sys.argv[2]
TOP = sys.argv[3] if len(sys.argv) > 3 else "top"

NWELL = 1
NWELL_REV = 3
OVERSIZE = 2.0          # um, per the LEVEL 3 rule

ly = db.Layout()
ly.read(IN_GDS)
dbu = ly.dbu
top = ly.cell(TOP)
if top is None:
    sys.exit(f"ERROR: no cell named {TOP!r} in {IN_GDS}")

li_nwell = ly.layer(NWELL, 0)
li_rev = ly.layer(NWELL_REV, 0)

nwell = db.Region(top.begin_shapes_rec(li_nwell)).merged()
before = db.Region(top.begin_shapes_rec(li_rev)).merged()
want = nwell.sized(int(round(OVERSIZE / dbu))).merged()

mismatch = (want ^ before).merged()
print(f"nwell polygons        : {nwell.count()}")
print(f"nwell_rev as shipped  : {before.count()}")
print(f"3.1.1 XOR before      : {mismatch.count()} polygon(s)")
for p in mismatch.each():
    b = p.bbox().to_dtype(dbu)
    print(f"    {b}  {b.width():.3f} x {b.height():.3f} um")

# drop the per-cell layer everywhere, then emit the derived mask flat on top
cleared = 0
for cell in ly.each_cell():
    if not cell.shapes(li_rev).is_empty():
        cell.shapes(li_rev).clear()
        cleared += 1
for poly in want.each():
    top.shapes(li_rev).insert(poly)

check = db.Region(top.begin_shapes_rec(li_rev)).merged()
residual = (nwell.sized(int(round(OVERSIZE / dbu))).merged() ^ check).merged()
print(f"cells cleared of layer {NWELL_REV}/0 : {cleared}")
print(f"nwell_rev regenerated : {check.count()} polygon(s)")
print(f"3.1.1 XOR after       : {residual.count()} polygon(s)")

ly.write(OUT_GDS)
print(f"wrote {OUT_GDS}")
