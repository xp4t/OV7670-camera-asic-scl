# OV7670 Camera Configuration ASIC (SCL 1.2µm)

This repository contains the full ASIC implementation flow for the OV7670 camera configuration interface, targeting the **SCL 1.2µm (C1D) two-layer metal process**. 

The flow covers everything from logic synthesis through physical design, static timing analysis, and final signoff GDSII generation, explicitly tailored to overcome the extreme routing challenges of a legacy two-layer process.

## Project Overview
- **Design:** OV7670 Camera I2C/SCCB Configuration Controller (`top`)
- **Technology Node:** SCL 1.2µm (C1D)
- **Metal Layers:** 2 (`metal1`, `metal2`)
- **Standard Cells:** 2,986 cells (1,395 logic gates, 1,309 inverters, 258 flip-flops, 24 buffers)
- **Cell Area:** 4.25 mm²
- **Clock Domains:** 
  - `i_top_clk` (20ns period, 50 MHz)
  - `i_top_pclk` (40ns period, 25 MHz)
  - `w_clk25m` (40ns period, 25 MHz)

---

## 1. Synthesis (Cadence Genus)
Logic synthesis was performed using Cadence Genus.
- **Output:** `syn/sweep/E4/top_netlist.v`
- **Constraints:** `syn/sweep/E4/top_synth.sdc`

---

## 2. Floorplanning & Place-and-Route (Cadence Innovus)
The defining challenge of this project was routing congestion. Modern standard cell densities easily choke older two-layer processes, resulting in thousands of unresolvable DRC shorts.

To achieve a clean route, a "Nuclear Option" strategy was employed in `pnr/pnr_nuclear.tcl`:
- **Core Utilization:** Capped at an extremely low **10%**.
- **Row Spacing:** Increased to **40µm** between every standard cell row, creating massive horizontal `metal1` routing highways.
- **I/O Pin Placement:** 105 I/O pins were placed with an explicit **40µm spacing** (`-spreadType CENTER -spacing 40.0`) to prevent pin-access congestion at the die edges.
- **Power Planning:** Strict adherence to 2-layer power ring routing.

**Results:**
NanoRoute completed successfully, reducing DRC violations from over 50 (in the 35% utilization version) down to **11 violations**.

---

## 3. Current Signoff Status

> **⚠️ THIS DESIGN IS NOT YET READY FOR FABRICATION.**

### Remaining Issues (as of 2026-08-10)

| # | Issue | Status |
|---|-------|--------|
| 1 | **4 metal SHORT violations** in clock-gating cells (`enl_reg` blockage conflicts) | `pnr/drc.rpt` |
| 2 | **7 SPACING violations** (clock-gating + 1 inter-net spacing) | `pnr/drc.rpt` |
| 3 | **No CTS** performed (ccopt_design never called) | Needs re-run |
| 4 | **Antenna check** not yet performed | Needs re-run |
| 5 | **ECO route** for DRC fix not yet completed | Needs re-run |

### Fix Plan
A fabrication-grade PnR script (`pnr/pnr_signoff_grade.tcl`) has been prepared that addresses all issues:
- Adds proper CTS using `ccopt_design`
- Runs `ecoRoute -fix_drc` for remaining violations
- Exports GDS with correct SCL foundry layer mapping (no post-processing needed)
- Preserves power distribution vias (no `editDelete`)
- Runs DRC, connectivity, and antenna checks inside Innovus
- Produces a single unified GDS for external KLayout verification

### What IS Verified

| ✅ Item | Evidence |
|---------|----------|
| **LEC passes** — 335/335 compare points equivalent | `lec/lec.log` |
| **STA is clean** — 0 setup/hold violations (WNS: +15.90ns setup, +0.45ns hold) | `sta/post_pnr_*.rpt` |
| **Synthesis correct** — 2,986 cells mapped | `reports/area.rpt`, `reports/gates.rpt` |

---

## 4. Static Timing Analysis (Synopsys PrimeTime)
STA was performed using Synopsys PrimeTime (`pt_shell`) across three critical stages. The scripts and reports are located in the `sta/` directory.

- **Post-Synthesis STA:** Uses `top_netlist.v` with estimated wireload models.
- **Post-Floorplan STA:** Verifies that physical constraints match logical intent before routing.
- **Post-PnR STA:** Uses the final `pnr_final.v` netlist paired with extracted RC parasitics (`pnr_final.spef`).

**Final Post-PnR Timing Results (QoR):**
Because the design was physically spread out to solve DRCs, cross-coupling capacitance was drastically reduced, resulting in spectacular timing closure.
- **Setup Violations:** 0 (WNS: +15.90 ns)
- **Hold Violations:** 0 (WNS: +0.45 ns)
- **Total Negative Slack (TNS):** 0.00 ns

---

## 5. Logical Equivalence Check (Cadence Conformal)
- **Golden:** RTL (`rtl/*.v`)
- **Revised:** Post-PnR netlist (`pnr/pnr_final.v`)
- **Result:** 335/335 compare points **PASS**
- **Report:** `lec/lec.log`

---

## Repository Structure
```
├── rtl/                    # Verilog RTL source files
├── syn/                    # Synthesis scripts and logs (Cadence Genus)
├── constraints.sdc         # Timing constraints
├── floorplanning/          # Floorplan scripts and MMMC setup
├── pnr/                    # Place-and-route scripts, reports, and outputs
│   ├── pnr_nuclear.tcl     # Current PnR script (10% util, 40um spacing)
│   ├── pnr_signoff_grade.tcl  # NEW: Fabrication-grade PnR script
│   ├── drc.rpt             # Innovus DRC report (11 violations)
│   └── pnr_final.v         # Post-PnR netlist
├── sta/                    # PrimeTime STA scripts and reports
├── lec/                    # Logical equivalence check
├── reports/                # Synthesis reports (area, power, timing, gates)
├── final_drc_check/        # KLayout DRC/LVS verification
│   ├── run_signoff_unified.sh  # NEW: Unified signoff script
│   └── lvs_os_scl_c1d.lvs     # SCL LVS rule deck
└── out/                    # Synthesis outputs
```

---

## Known Limitations
- **Die size:** 10% core utilization results in a physically large die. This is a cost/yield trade-off necessitated by the 2-layer metal routing constraint.
- **Clock-gating cells:** The `LTCL11`-based ICG cells have internal routing conflicts with NanoRoute. Disabling clock gating in synthesis (`set_attribute lp_insert_clock_gating false`) may be necessary if ECO routing cannot resolve these.
- **CDC checking:** Cross-clock-domain checking (recommended in `lec.log`) has not been performed. Three async clock domains exist in this design.
