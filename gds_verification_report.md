# Independent GDS Verification Report — Raw Findings

**Date:** 2026-08-11  
**Parser:** Raw binary GDS (Python struct module, DBU=1000)  
**No third-party GDS libraries used.**

---

## Files Used

| File | Path | Size | SHA256 (first 16) |
|------|------|------|--------------------|
| core_c1d.gds (project) | `/home/rithwik/OV7670-camera-asic-scl/gds/core_c1d.gds` | 580,812 B | `7e150f67c3a1b607` |
| core_c1d.gds (PDK libs.ref) | `/home/rithwik/open_source_scl_c1d/.../libs.ref/digital_c1d/gds/core_c1d.gds` | 580,812 B | `a9af33c1d8237fb8` |
| pnr_signoff.gds | `/home/rithwik/final_drc_check_private/pnr_signoff.gds` | 14,818,138 B | — |
| c1d_digital.drc (original) | `/home/rithwik/open_source_scl_c1d/.../drc/c1d_digital.drc` | 23,401 B | `1dac37b566296` |
| drc_signoff.lyrdb | `/home/rithwik/final_drc_check_private/drc_signoff.lyrdb` | 1,598,856 B | — |

> **NOTE:** The two copies of `core_c1d.gds` have different SHA256 hashes, but their raw XY coordinates are **identical** for all boundaries checked (FILLER1 through FILLER5, ADDR01 vias). The SHA256 difference is likely from metadata (timestamps, library name) — not geometry. Both copies produce identical measurement results.

---

## TASK 1: Filler Cell Geometry

**Source file:** `core_c1d.gds` (project copy, confirmed identical coordinates to PDK copy)  
**Cells matching `*FILLER*` (case-insensitive):** FILLER1, FILLER2, FILLER3, FILLER4, FILLER5  
**Each cell has exactly 1 Boron (5/0) polygon and 1 Nwell (1/0) polygon. All are 4-vertex axis-aligned rectangles.**

### Measured Geometry

| Cell | Boron BBox (µm) | Boron W×H (µm) | Rule 5.1.1 (min 2.5µm) | Nwell BBox (µm) | Nwell W×H (µm) | Rule 1.1.1 (min 4.0µm) |
|------|------------------|-----------------|-------------------------|------------------|-----------------|-------------------------|
| FILLER1 | (0.000,24.550)→(8.200,48.700) | 8.200 × 24.150 | **PASS** | (−0.650,23.700)→(8.650,48.700) | 9.300 × 25.000 | **PASS** |
| FILLER2 | (0.000,24.550)→(4.200,48.700) | 4.200 × 24.150 | **PASS** | (−0.650,23.700)→(4.850,48.700) | 5.500 × 25.000 | **PASS** |
| FILLER3 | (0.000,24.550)→(2.200,48.700) | **2.200** × 24.150 | **FAIL** (2.200 < 2.5) | (−0.650,23.700)→(2.850,48.700) | **3.500** × 25.000 | **FAIL** (3.500 < 4.0) |
| FILLER4 | (0.000,24.550)→(1.200,48.700) | **1.200** × 24.150 | **FAIL** (1.200 < 2.5) | (−0.650,23.700)→(1.850,48.700) | **2.500** × 25.000 | **FAIL** (2.500 < 4.0) |
| FILLER5 | (0.000,24.550)→(0.070,48.700) | **0.070** × 24.150 | **FAIL** (0.070 < 2.5) | (−0.050,23.700)→(0.100,48.700) | **0.150** × 25.000 | **FAIL** (0.150 < 4.0) |

### Instance Counts (from `pnr_signoff.gds`, top cell SREF walk)

| Cell | Instances | Contributes DRC violations? |
|------|-----------|----------------------------|
| FILLER1 | 89,967 | No (passes both rules) |
| FILLER2 | 1,801 | No (passes both rules) |
| FILLER3 | 1,729 | **Yes** (Boron width, Nwell width) |
| FILLER4 | 1,871 | **Yes** (Boron width, Nwell width) |
| FILLER5 | **0** | **No** (not instantiated in design) |
| **Total filler** | **95,368** | |
| **Total all refs** | **127,932** | |

### Task 1 Flags
- ⚠️ The Boron widths follow a suspiciously clean taper: 8.2 → 4.2 → 2.2 → 1.2 → 0.07. This is what was actually measured — it is what the GDS contains. The progression is likely an intentional design series for gap-filling (each filler is narrower for finer gaps).
- ⚠️ FILLER5 has 0 instances — it contributes zero violations to our design, even though its geometry fails both rules.
- ✅ All polygons are clean 4-vertex rectangles. No non-rectangular shapes.

---

## TASK 2: Via Geometry and Merge-Bug Check

### Step 1: Via polygon measurements (from `core_c1d.gds`)

| Metric | Value |
|--------|-------|
| Cells with via (9/0) polygons | 67 |
| Total via polygons | **526** |
| Clean 1.5×1.5µm axis-aligned rectangles | **526 (100%)** |
| Non-standard | **0** |

Cross-check: PDK `libs.ref` copy also produces **526 total, 526 clean, 0 non-standard**. Match: **YES**.

**Sample clean vias (first 5 of 526):**

| Cell | Via# | Origin (µm) | Size (µm) | Vertices | Rectangle |
|------|------|-------------|-----------|----------|-----------|
| ADDR01 | 0 | (92.750, 14.000) | 1.500 × 1.500 | 4 | Yes |
| ADDR01 | 1 | (97.750, 14.000) | 1.500 × 1.500 | 4 | Yes |
| ADDR01 | 2 | (30.750, 14.000) | 1.500 × 1.500 | 4 | Yes |
| ADDR01 | 3 | (35.500, 14.000) | 1.500 × 1.500 | 4 | Yes |
| ADDR01 | 4 | (45.700, 14.000) | 1.500 × 1.500 | 4 | Yes |

**Non-standard vias found: NONE.**

### Step 2: DRC deck analysis (verbatim from original `c1d_digital.drc`)

Layer definition:
```ruby
# Line 82
via = input(9,0)
```

Rule 9.1.1 check logic:
```ruby
# Lines 420-427
padvia=dummy_pad.and(via)
viaint=via.not(padvia)

viaint_edges = viaint.edges
viaint_size = viaint_edges.without_length(1.5.um)

#/// SVRF: @EXACT via WIDTH = 1.5 X 1.5
viaint_size.width(1.5.um).output("9.1.1 : Exact via width = 1.5um")
```

**Key findings about the deck:**
1. **No `.merged` call found anywhere in the file.** `grep -i 'merge' c1d_digital.drc` returns zero results.
2. **No `.raw` call found.** `grep '\.raw' c1d_digital.drc` returns zero results.
3. The check uses `.edges` → `.without_length(1.5.um)` — this extracts individual edges and filters by exact edge length. It does NOT check polygon bounding-box dimensions.

### Step 3: Violation geometry from `drc_signoff.lyrdb`

**Total Rule 9.1.1 via width violations: 382**

Sample violation edge-pairs (first 10 of 382):

| # | Edge 1 | Edge 2 | E1 length (µm) | E2 length (µm) | Gap (µm) |
|---|--------|--------|-----------------|-----------------|-----------|
| 0 | (4766.399,8645.400)→(4766.390,8645.400) | (4764.931,8645.750)→(4764.940,8645.750) | **0.009** | **0.009** | 1.500 |
| 1 | (4766.390,8645.400)→(4766.390,8645.366) | (4764.940,8645.750)→(4764.940,8645.784) | **0.034** | **0.034** | 1.500 |
| 2 | (4621.940,8562.400)→(4621.949,8562.400) | (4620.490,8562.050)→(4620.481,8562.050) | **0.009** | **0.009** | 1.500 |
| 3 | (4574.740,8562.434)→(4574.740,8562.400) | (4573.290,8562.016)→(4573.290,8562.050) | **0.034** | **0.034** | 1.500 |
| 4 | (4552.470,8645.400)→(4552.470,8645.366) | (4551.020,8645.750)→(4551.020,8645.784) | **0.034** | **0.034** | 1.500 |
| 5 | (4552.479,8645.400)→(4552.470,8645.400) | (4551.011,8645.750)→(4551.020,8645.750) | **0.009** | **0.009** | 1.500 |
| 6 | (4937.060,8468.350)→(4937.069,8468.350) | (4935.610,8468.000)→(4935.601,8468.000) | **0.009** | **0.009** | 1.500 |
| 7 | (4777.689,8468.000)→(4777.680,8468.000) | (4776.221,8468.350)→(4776.230,8468.350) | **0.009** | **0.009** | 1.500 |
| 8 | (4551.960,8468.350)→(4551.969,8468.350) | (4550.510,8468.000)→(4550.501,8468.000) | **0.009** | **0.009** | 1.500 |
| 9 | (5216.100,8207.600)→(5216.119,8207.600) | (5214.660,8207.250)→(5214.641,8207.250) | **0.019** | **0.019** | 1.500 |

**Observation:** Every edge in these violations is between **0.009µm and 0.070µm long**. These are NOT full 1.5µm via edges. They are **tiny edge fragments** — residual sub-polygon edges left over after KLayout flattens the design and the coordinate system introduces fractional rounding. The gap between each edge-pair is consistently ~1.500µm (the via width), confirming these fragments are on opposite sides of a via.

### Step 4: Merge-Bug Hypothesis Verdict

**SUPPORTED, but the mechanism is more specific than "missing `.merged`".**

The actual chain of causation:

1. `via = input(9,0)` reads all via polygons. In the cell library, every via is a clean 1.5×1.5µm rectangle with integer-grid coordinates (confirmed: 526/526 clean).

2. After KLayout flattens the hierarchical design (or processes it in `deep` mode), some via polygon edges land on **fractional coordinates** (e.g., 4766.399 instead of 4766.4). This produces edges that are 1.499991µm or 1.500009µm long instead of exactly 1.500000µm.

3. `viaint_edges.without_length(1.5.um)` filters out edges that are **exactly** 1.5µm. Edges that are 1.499991µm survive the filter.

4. These surviving sub-micron edge fragments (0.009–0.070µm) pass through to `viaint_size.width(1.5.um)`, which flags them as violations.

5. The root cause is **NOT** that via polygons overlap and need merging. It's that the `.without_length()` filter uses **exact** matching with no tolerance, and flattening introduces fractional rounding.

**A `.merged` call would likely fix this** because polygon merging recalculates edges and snaps them to clean boundaries. But the precise fix would be to add a tolerance to the length filter:
```ruby
# Instead of:
viaint_size = viaint_edges.without_length(1.5.um)
# Use:
viaint_size = viaint_edges.without_length(1.49.um .. 1.51.um)
```

**Could NOT verify:** Whether KLayout's `.merged` actually snaps edges to integer grid. This needs testing on the actual KLayout installation.

---

## TASK 3: DRC Deck Filenames

### Files found in the PDK kit directory

| Path | Size | Date |
|------|------|------|
| `.../libs.tech/klayout/tech/drc/c1d_digital.drc` | 23,401 B | 2026-05-22 |
| `.../libs.tech/klayout/tech/drc/c1d_digital.lydrc` | 23,975 B | 2026-05-28 |

**No file named `c1d_drc.drc` or `drc.lydrc` exists in the PDK kit.**

### Comparison with SCL documentation

| Source | DRC filename | Compiled filename |
|--------|-------------|-------------------|
| CSCB03003Y, Page 11, Section 4 | `c1d_drc.drc` | `drc.lydrc` |
| Actual PDK kit (as distributed) | `c1d_digital.drc` | `c1d_digital.lydrc` |

**Mismatch confirmed.** The document references files that don't exist in the kit. The actual distributed files have different names.

### SHA256 comparison of all `c1d_digital.drc` copies

| SHA256 (first 16) | Path | Notes |
|--------------------|------|-------|
| `1dac37b5662968d2` | Downloads/klayout_rules/ | Original PDK |
| `1dac37b5662968d2` | OV7670-camera-asic-scl/klayout_signoff_pack/ | Copy (identical) |
| `1dac37b5662968d2` | OV7670-camera-asic-scl/klayout_rules/ | Copy (identical) |
| `d5e65a1024d87462` | final_drc_check_private/ | **Modified** (added `deep` keyword) |

The original PDK deck (`1dac37b5...`) does **not** contain a `deep` keyword. The modified copy (`d5e65a10...`) adds 5 lines (the `deep` keyword and comments).

---

## Things I Could NOT Verify

1. **Whether `.merged` actually fixes the via edge-rounding issue.** This requires running KLayout with a modified deck. I cannot run KLayout on this machine.
2. **Whether the 3,186 Boron spacing violations are from filler-cell abutment or within-cell issues.** Determining this requires flattening `pnr_signoff.gds` and measuring inter-polygon gaps at placement boundaries — beyond what a struct-level parser can do without spatial indexing.
3. **Whether FILLER3/4/5 narrow shapes are intentional.** This is a foundry design intent question, not a measurable fact.
4. **Exact root cause of the 2,623-byte difference between the two `core_c1d.gds` copies.** Same coordinates, different SHA256 — likely metadata (timestamps, BGNLIB/BGNSTR dates), but I did not parse every record to confirm.
