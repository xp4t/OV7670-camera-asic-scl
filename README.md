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

## The 2-Layer Metal Routing Challenge & Solution

The defining challenge of this project was routing congestion. Modern standard cell densities easily choke older two-layer processes, resulting in thousands of unresolvable DRC shorts.

Earlier attempts to reach a clean DRC involved "hacking" the GDS—running NanoRoute with high utilization, finding shorts in the clock-gating cells, and then deleting power vias (`editDelete -object_type Via -net VDD`) to blindly pass DRC. This resulted in two disconnected GDS versions, neither of which were truly fabrication-ready.

**How we fixed it:**
We performed a full "Nuclear Option" reset of the physical design to generate a genuinely fabrication-grade, 100% clean layout:

1. **Disabled Clock Gating in Synthesis**: We identified that automated clock gating insertion (Genus `lp_insert_clock_gating`) was instantiating `LTCL11` cells. These specific cells contained internal metal blockages that, when placed on a 2-metal process, created unresolvable shorts with NanoRoute. We re-synthesized the design with clock gating disabled, eliminating the source of the DRC shorts.
2. **10% Core Utilization**: The design utilization was capped at an extremely low 10%.
3. **40µm Row & Pin Spacing**: We increased the row spacing to 40µm between every standard cell row, creating massive horizontal `metal1` routing highways. The 105 I/O pins were also spaced at 40µm to prevent pin-access congestion.
4. **Non-timing-driven Routing**: We disabled timing-driven routing in Innovus, as timing optimization was causing the router to pack wires too densely and create shorts.
5. **Native GDS Mapping**: We created a unified `pnr_signoff_grade.tcl` script that uses a correct stream-out map directly from Innovus, producing a single, verified GDSII file.

---

## 1. Synthesis (Cadence Genus)
Logic synthesis was performed using Cadence Genus without clock gating.
- **Output:** `syn/signoff/top_netlist.v`
- **Constraints:** `syn/signoff/top_synth.sdc`

---

## 2. Floorplanning & Place-and-Route (Cadence Innovus)
- **Script:** `pnr/pnr_signoff_grade.tcl`
- **Final GDS:** `final_drc_check/pnr_signoff.gds`

**Results:** NanoRoute completed successfully with exactly **0 DRC violations** and perfectly intact power nets.

---

## 3. Final Signoff Status: READY FOR FABRICATION

**✅ 100% DRC / LVS Clean**

The single unified GDS file (`pnr_signoff.gds`) was verified using KLayout with the SCL Foundry rule decks. 
- **DRC:** 0 Violations (`drc_signoff.lyrdb`)
- **LVS:** Netlists match! (17,018 devices and nets verified successfully, `log.txt`)

| ✅ Item | Evidence |
|---------|----------|
| **DRC Clean (Innovus)** | `pnr/drc_final.rpt` |
| **Connectivity Clean (Innovus)** | `pnr/connectivity_final.rpt` |
| **DRC Clean (KLayout)** | `final_drc_check/drc_signoff.lyrdb` |
| **LVS Clean (KLayout)** | `final_drc_check/log.txt` |
| **LEC passes** — 335/335 compare points equivalent | `lec/lec.log` |
| **STA is clean** — 0 setup/hold violations (WNS: +15.90ns setup, +0.45ns hold) | `sta/post_pnr_*.rpt` |

---

## Repository Structure
```
├── rtl/                    # Verilog RTL source files
├── syn/                    # Synthesis scripts and logs (Cadence Genus)
├── constraints.sdc         # Timing constraints
├── floorplanning/          # Floorplan scripts and MMMC setup
├── pnr/                    # Place-and-route scripts, reports, and outputs
│   └── pnr_signoff_grade.tcl  # Fabrication-grade PnR script
├── sta/                    # PrimeTime STA scripts and reports
├── lec/                    # Logical equivalence check
├── final_drc_check/        # Final verified results ready for tapeout
│   ├── run_signoff.sh         # Unified signoff script
│   ├── pnr_signoff.gds        # The final, flawless layout
│   ├── pnr_signoff.v          # Final netlist
│   ├── drc_signoff.lyrdb      # KLayout DRC passing database
│   ├── layout_extracted_signoff.cir # Extracted SPICE for LVS
│   └── log.txt                # Signoff log showing LVS match
└── out/                    # Synthesis outputs
```

*Note: Confidential SCL foundry technology files (.drc, .lvs, .lydrc, .cdl, .tf, .lef, .lib, etc.) are excluded from this public repository.*
