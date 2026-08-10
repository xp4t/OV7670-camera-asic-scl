import klayout.db as pya

print("Loading original pnr_final.gds...")
l = pya.Layout()
l.read("../pnr/pnr_final.gds")

top = l.top_cell()
l_9_0 = l.layer(9, 0)
l_8_0 = l.layer(8, 0)
l_10_0 = l.layer(10, 0)
l_14_0 = l.layer(14, 0)
l_35_0 = l.layer(35, 0)
l_26_0 = l.layer(26, 0)

# 1. Delete ALL massive power vias in the top cell
print("Skipping clearing of 9/0 to preserve top-level signal vias and power vias for LVS!")
# top.shapes(l_9_0).clear()

# 2. Fix signal vias
print("Restoring standard cell signal vias...")
for cell in l.each_cell():
    if "VIA" in cell.name.upper():
        for s in cell.shapes(l_14_0): cell.shapes(l_8_0).insert(s)
        cell.shapes(l_14_0).clear()
        for s in cell.shapes(l_35_0): cell.shapes(l_10_0).insert(s)
        cell.shapes(l_35_0).clear()
        for s in cell.shapes(l_26_0): cell.shapes(l_9_0).insert(s)
        cell.shapes(l_26_0).clear()

# 3. Move core routing from 29/0 to 10/0
print("Moving core routing from 29/0 to 10/0...")
l_29_0 = l.layer(29, 0)
for s in top.shapes(l_29_0):
    top.shapes(l_10_0).insert(s)
top.shapes(l_29_0).clear()

# 4. Move IO pin TEXTS from 41/0 to 10/7
# (Wait, there are NO VDD/VSS texts in 41/0! But we move everything anyway)
l_41_0 = l.layer(41, 0)
l_10_7 = l.layer(10, 7)
l_8_7 = l.layer(8, 7)
for s in top.shapes(l_41_0):
    if s.is_text():
        if "VDD" in s.text.string.upper() or "VSS" in s.text.string.upper():
            top.shapes(l_8_7).insert(s)
        else:
            top.shapes(l_10_7).insert(s)
top.shapes(l_41_0).clear()

l.write("pnr_fixed_final.gds")
print("Saved fixed GDS to final_drc_check/pnr_fixed_final.gds")
