# OV7670 Camera Configuration ASIC (SCL 1.2µm)

This repository contains the full ASIC implementation flow for the OV7670 camera configuration interface, targeting the **SCL 1.2µm (C1D) two-layer metal process**. 

The flow covers everything from logic synthesis through physical design, static timing analysis, and final signoff GDSII generation, explicitly tailored to overcome the extreme routing challenges of a legacy two-layer process.

## Project Overview
- **Design:** OV7670 Camera I2C/SCCB Configuration Controller (`top`)
- **Technology Node:** SCL 1.2µm (C1D)
- **Metal Layers:** 2 (`metal1`, `metal2`)
- **Clock Domains:** 
  - `i_top_clk` (20ns period, 50 MHz)
  - `i_top_pclk` (40ns period, 25 MHz)
  - `w_clk25m` (40ns period, 25 MHz)

---

## Current Status

> **⚠️ THIS DESIGN IS NOT YET READY FOR FABRICATION.**

### KLayout DRC Results (4,738 violations in `drc_signoff.lyrdb`)

| Rule | Count | Category | Root Cause |
|------|-------|----------|------------|
| Min Boron spacing = 1.5µm | 3,181 | Device-layer | Inter-cell abutment boundaries (flat DRC mode) |
| Min Boron width = 2.5µm | 602 | Device-layer | Standard cell internal geometry |
| Exact via width = 1.5µm | 382 | Off-grid | DBU/grid mismatch producing non-Manhattan vias |
| Via-to-Poly spacing = 1.2µm | 274 | Device-layer | Standard cell internal clearance |
| **Metal2-to-Metal2 spacing = 1.7µm** | **169** | **Routing** | **LEF OBS vs GDS mismatch: 36 near-shorts (<0.5µm gap)** |
| Min Nwell width = 4.0µm | 77 | Device-layer | Standard cell internal geometry |
| Via-to-contact spacing | 39 | Interface | Routing vias too close to cell contacts |
| Others | 14 | Mixed | Boron-Ndiff, via-via, Metal1, Nwell spacing |

### Analysis

The violations fall into two distinct categories:

**1. Device-layer violations (4,555 = 96%):** Boron, Nwell, via width, via-to-poly — these are all on layers Innovus never routes. They exist inside the merged standard cell GDS (`core_c1d.gds`). The KLayout DRC deck runs in *flat* mode (no `deep` block), flattening all 100,966 cell instances and flagging inter-cell implant boundaries. 61.5% of Boron spacing violations have gaps <0.5µm — these are at cell abutment edges where implant layers are designed to merge. A hierarchical DRC run may reclassify these.

**2. Metal2 routing violations (169 = the critical 4%):** These are real collisions between Innovus's routed Metal2 tracks and the actual Metal2 geometry inside standard cells. The LEF abstract OBS shapes don't perfectly represent the GDS geometry — after merge, the actual metal extends beyond what the LEF declared. Gap measurements from the violation coordinates:
- 36 critical (<0.5µm, including gaps as small as 0.04µm)
- 32 severe (0.5–1.0µm)
- 38 moderate (1.0–1.5µm)
- 63 marginal (1.5–1.7µm)

### What IS Verified

| ✅ Item | Evidence |
|---------|----------|
| **Innovus DRC clean** (routing-domain only, pre-merge) | `pnr/drc_final.rpt` |
| **Connectivity clean** | `pnr/connectivity_final.rpt` |
| **LVS match** (17,018 devices and nets) | `final_drc_check/log.txt` |
| **LEC passes** — 335/335 compare points equivalent | `lec/lec.log` |
| **STA clean** — 0 setup/hold violations | `sta/post_pnr_*.rpt` |

### Known Gaps
- Antenna check report (`antenna_final.rpt`) was not generated
- `lvs_signoff.lvsdb` database file was not written (text output confirms match but no database for independent verification)

---

## The 2-Layer Metal Routing Challenge

### What Failed (v1)
The original PnR flow had clock gating enabled, creating `LTCL11` ICG cells with internal metal blockages that produced unresolvable shorts. The "fix" involved deleting all power vias (`editDelete -object_type Via -net VDD/VSS`) and running DRC/LVS against two different GDS files — neither was fabrication-ready.

### What Improved (v1 → v2)
1. **Disabled Clock Gating** in synthesis — eliminated `LTCL11` blockage shorts entirely
2. **Single GDS file** — one `pnr_signoff.gds` used for both DRC and LVS
3. **No power via deletion** — all VDD/VSS vias preserved
4. **10% core utilization, 40µm row spacing** — massive routing highways
5. **Non-timing-driven routing** — prevents dense wire packing

### What Still Needs Fixing (v2 → v3)
1. Metal2 routing vs cell OBS mismatch (169 violations)
2. Via grid alignment (382 off-grid vias)
3. Device-layer violations need hierarchical DRC to classify
4. Antenna check needs to run to completion

---

## Repository Structure
```
├── rtl/                    # Verilog RTL source files
├── syn/                    # Synthesis scripts and logs (Cadence Genus)
│   └── signoff/            # Clock-gating-free synthesis output
├── constraints.sdc         # Timing constraints
├── floorplanning/          # Floorplan scripts and MMMC setup
├── pnr/                    # Place-and-route scripts, reports, and outputs
│   └── pnr_signoff_grade.tcl  # Fabrication-grade PnR script (v2)
├── sta/                    # PrimeTime STA scripts and reports
├── lec/                    # Logical equivalence check
├── final_drc_check/        # KLayout DRC/LVS verification
│   ├── run_signoff.sh         # Unified signoff script
│   ├── pnr_signoff.gds        # Current layout (4,738 KLayout DRC violations)
│   ├── pnr_signoff.v          # Final netlist
│   ├── drc_signoff.lyrdb      # KLayout DRC report (4,738 violations)
│   ├── layout_extracted_signoff.cir # Extracted SPICE for LVS
│   └── log.txt                # Signoff log showing LVS match
└── out/                    # Synthesis outputs
```

*Note: Confidential SCL foundry technology files (.drc, .lvs, .lydrc, .cdl, .tf, .lef, .lib, etc.) are excluded from this public repository.*
