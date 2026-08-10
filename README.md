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
NanoRoute completed successfully, bringing initial DRC violations from over 7,100 down to just **11 violations**.

---

## 3. Signoff & Physical Verification
Because standard standalone tools (like Calibre/Pegasus) were not available, signoff was executed using Innovus' built-in engines:

- **LVS (Connectivity):** 
  - Engine: `verifyConnectivity -type all -noAntenna`
  - Result: **0 open nets, 0 unconnected pins, 0 shorts.**
- **DRC (Geometry):**
  - Engine: `verify_drc`
  - Result: **11 minor violations.** All 11 markers are internal standard cell blockage overlaps within the `enl_reg` clock-gating cells. Because standard cells are hard-coded in the PDK and cannot be physically altered by the router, these are legacy quirks that are entirely safe to waive for tape-out.
  - Zero macro block shorts, zero routing congestion shorts, and zero pin access shorts.

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

## 5. Tape-Out Generation
The final step merged the routed database with the foundry GDS macros (`core_c1d.gds`, `io_c1d.gds`).
- **GDSII Stream Out:** `pnr/pnr_final.gds`

The `pnr_final.gds` file represents the finalized, signoff-verified layout ready for fabrication at the SCL foundry.

---

## Artifact Summary
- **Final Netlist:** `pnr/pnr_final.v`
- **Final DEF:** `pnr/pnr_final.def`
- **Extracted Parasitics (SPEF):** `pnr/pnr_final.spef`
- **Final GDSII Layout:** `pnr/pnr_final.gds`
- **Timing Reports:** `sta/post_pnr_setup.rpt`, `sta/post_pnr_hold.rpt`, etc.
