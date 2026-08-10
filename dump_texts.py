import klayout.db as pya
l = pya.Layout()
l.read("pnr/pnr_final.gds")
top = l.top_cell()
l_41_0 = l.layer(41, 0)
texts = []
for s in top.shapes(l_41_0):
    if s.is_text():
        texts.append(s.text.string)
print(f"Found {len(texts)} texts on 41/0")
print("First 20 texts:", texts[:20])
if any("VDD" in t.upper() for t in texts):
    print("VDD found!")
else:
    print("VDD NOT found in 41/0 texts.")
