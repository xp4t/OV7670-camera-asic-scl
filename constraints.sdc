#############################################################################
# constraints.sdc — OV7670 Camera ASIC (top)
# Target  : SCL 1.2um Digital (C1D)
# Tool    : Cadence Genus
#
# Clock names, periods, I/O delays, and false-path exceptions carried over
# from the prior SAED32 Design Compiler script (synth.tcl), since this is
# the same RTL retargeted to the SCL 1.2um process. Two items from that
# script are SAED32-specific and are NOT included here — see notes at the
# bottom of this file.
#############################################################################

# ---------------------------------------------------------------------------
# Clocks
# ---------------------------------------------------------------------------
set CLK_TOP_PERIOD      20.0    ;# i_top_clk  -> 50 MHz
set CLK_PCLK_PERIOD     40.0    ;# i_top_pclk -> 25 MHz (camera pixel clock)
set CLK_VGA_PERIOD      40.0    ;# w_clk25m   -> 25 MHz (VGA pixel clock)

set CLK_TOP_NAME        i_top_clk
set CLK_PCLK_NAME       i_top_pclk
set CLK_VGA_NAME        w_clk25m

create_clock -name $CLK_TOP_NAME  -period $CLK_TOP_PERIOD  [get_ports $CLK_TOP_NAME]
create_clock -name $CLK_PCLK_NAME -period $CLK_PCLK_PERIOD [get_ports $CLK_PCLK_NAME]

# Confirmed in top.v: w_clk25m is a top-level input port (line 7,
# "input wire w_clk25m"), despite the w_ prefix. It's a real primary
# clock input, not internally generated -- treat as such.
create_clock -name $CLK_VGA_NAME -period $CLK_VGA_PERIOD [get_ports $CLK_VGA_NAME]

# i_top_clk, i_top_pclk, and w_clk25m are three independent clock domains:
# - i_top_clk:  system clock
# - w_clk25m:   drives VGA logic AND feeds o_top_xclk to the camera sensor
# - i_top_pclk: camera pixel clock, generated OFF-CHIP by the sensor from
#               the XCLK it receives (i.e. derived from w_clk25m, but
#               through external analog sensor timing Genus can't model
#               as a clean divide relationship)
# All three are treated as mutually asynchronous. NOTE: the original DC
# script only declared i_top_clk vs i_top_pclk as async and never included
# w_clk25m in that grouping -- this was a gap in the original script, added
# here for correctness.
set_clock_groups -name CG_ASYNC_DOMAINS -asynchronous \
    -group [get_clocks $CLK_TOP_NAME] \
    -group [get_clocks $CLK_PCLK_NAME] \
    -group [get_clocks $CLK_VGA_NAME]

set_clock_uncertainty -setup 0.10 [all_clocks]
set_clock_uncertainty -hold  0.05 [all_clocks]
set_clock_transition   0.10 [all_clocks]

# ---------------------------------------------------------------------------
# I/O delays
# ---------------------------------------------------------------------------
set NON_CLOCK_INPUTS [remove_from_collection [all_inputs] \
    [get_ports "$CLK_TOP_NAME $CLK_PCLK_NAME $CLK_VGA_NAME"]]

set_input_delay  -max 4.0 -clock $CLK_TOP_NAME $NON_CLOCK_INPUTS
set_input_delay  -min 0.5 -clock $CLK_TOP_NAME $NON_CLOCK_INPUTS
set_output_delay -max 4.0 -clock $CLK_TOP_NAME [all_outputs]
set_output_delay -min 0.5 -clock $CLK_TOP_NAME [all_outputs]

set_input_transition 0.15 [all_inputs]

# ---------------------------------------------------------------------------
# External BRAM I/O delays (domain-specific overrides)
# Port A (write): driven by i_top_pclk domain
# Port B (read):  driven by w_clk25m domain
# ---------------------------------------------------------------------------
set BRAM_WR_PORTS [get_ports {o_bram_clka o_bram_ena o_bram_wea \
    o_bram_addra* o_bram_dina*}]
set BRAM_RD_PORTS [get_ports {o_bram_clkb o_bram_enb o_bram_web \
    o_bram_addrb*}]

set_output_delay -max 4.0 -clock $CLK_PCLK_NAME $BRAM_WR_PORTS
set_output_delay -min 0.5 -clock $CLK_PCLK_NAME $BRAM_WR_PORTS

set_output_delay -max 4.0 -clock $CLK_VGA_NAME  $BRAM_RD_PORTS
set_output_delay -min 0.5 -clock $CLK_VGA_NAME  $BRAM_RD_PORTS

# i_bram_doutb returns from external SRAM on the read clock domain
set_input_delay  -max 4.0 -clock $CLK_VGA_NAME [get_ports i_bram_doutb*]
set_input_delay  -min 0.5 -clock $CLK_VGA_NAME [get_ports i_bram_doutb*]

# ---------------------------------------------------------------------------
# Drive / Load — UNRESOLVED, see notes at bottom
# ---------------------------------------------------------------------------
# Original DC script used SAED32 cells INVX4_RVT (driving cell) and
# INVX1_RVT (load reference) — these do not exist in the SCL 1.2um library.
# Replace <SCL_INV_CELL> / <SCL_INV_PIN> below with actual cell/pin names
# from your SCL .lib once you've confirmed them (open the .lib and search
# for an inverter cell, e.g. grep -i "^cell (INV" lib/nldm_tt_27_1p5.lib).
#
set_driving_cell -lib_cell INVR04 -library LS_TT -pin OUT1 $NON_CLOCK_INPUTS
# FIX: load_of LS_TT/INVR01/IN1 failed with TUI-61 "object not found" --
# LS_TT is our own create_library_set alias, not the real internal Liberty
# library name Genus uses for object lookup (the log shows the actual
# names are things like 'ss_125_2p45', 'scl1u_pads_max' -- taken straight
# from each .lib's internal `library (...)` statement, not our MMMC
# names). Rather than hardcode the real tt-corner library name, use
# get_lib_pins with a wildcarded library so Genus searches across
# whatever's loaded instead of requiring an exact name match.
set_load [expr {4 * [load_of [get_lib_pins */INVR01/IN1]]}] [all_outputs]
# NOTE: INVR04 chosen by position in the R01(weak)-R06(strong) naming
# sequence as a proportional stand-in for the old "X4" driving strength.
# Verify against actual IN1 capacitance scaling across INVR01-06 if you
# want a more precise match (see chat for the grep to check this).

# ---------------------------------------------------------------------------
# Design rule constraints
# ---------------------------------------------------------------------------
set_max_fanout     16   [current_design]
# FIX: 0.15 was rejected -- TIM-119 "overly restrictive for this
# technology", tool requires at least 751ps (0.751ns) as a floor for
# this SCL 1.2um process. 0.15ns was copied from the SAED32 script
# without adjusting for the much coarser SCL process's actual
# transition-time capability. Set comfortably above the floor.
set_max_transition 1.0  [current_design]

# ---------------------------------------------------------------------------
# Timing exceptions
# ---------------------------------------------------------------------------
catch { set_false_path -from [get_ports i_top_rst] }

# Debounce reset paths — instance/pin names below assume the same hierarchy
# names as the prior SAED32 netlist (OV7670_cam/cam_btn_start_db,
# top_btn_db). Verify these instances exist with the same names after
# elaborating against the SCL flow's RTL — if module/instance names shifted,
# these catch{} blocks will just silently match nothing and give you an
# unconstrained reset path, so don't skip checking.
# cam_btn_start_db RSTB exceptions REMOVED (same reasoning as top_btn_db
# above): both instances use the same debouncer.v module, which has a
# fully synchronous i_rst inside a posedge-i_clk-only always block -- no
# async reset pin, so no RSTB pin exists in the synthesized netlist. The
# actual Genus run confirmed this directly: get_pins on
# 'OV7670_cam/cam_btn_start_db/counter_reg*/RSTB' and '.../r_sample_reg/RSTB'
# both failed with SDC-208 "could not find requested search value", and
# the resulting empty object broke set_false_path with TUI-61. Whatever
# port originally connects to i_top_cam_start (or drives this instance's
# i_btn_in) is still covered if it traces back through a port with its
# own blanket false-path, same as i_top_rst above -- check top.v for the
# actual driving port/signal if you need an explicit exception here.
# top_btn_db in top.v is a reset debouncer, NOT a generic button debouncer:
#   debouncer #(.DELAY(240_000)) top_btn_db (
#       .i_clk(i_top_clk), .i_rst(1'b0),
#       .i_btn_in(~i_top_rst), .o_btn_db(w_rst_btn_db) );
# Its i_btn_in is driven by ~i_top_rst, not a separate i_top_btn port --
# the original DC script's "i_top_btn" was wrong for this instance (either
# a leftover from an earlier RTL version or a copy error). Corrected below.
#
# Because i_top_rst already has a blanket set_false_path from its port
# above, these two lines are almost certainly redundant -- any path
# through the inverter (~i_top_rst -> i_btn_in -> ... -> RSTB) still
# traces back to the i_top_rst port and is already exempted. Left in
# explicitly for clarity/robustness in case the blanket exception is ever
# removed, but you can safely delete these two if you want a leaner file.
#
# Also note: i_rst on this instance is tied to 1'b0 (constant, per the
# "FIX 3" comment in top.v) -- Genus will likely optimize that input away
# entirely during synth_generic. Doesn't affect this exception (which
# targets the i_btn_in path, not i_rst), just flagging so you're not
# surprised if i_rst disappears from the netlist.
# top_btn_db RSTB exceptions REMOVED (see chat): debouncer.v uses i_rst as
# a fully synchronous reset (if(i_rst) inside posedge-i_clk-only always
# block) -- there is no async reset pin on counter/r_sample, so no RSTB
# pin exists in the synthesized netlist for these registers. The
# original DC script's RSTB exception was for a different (async-reset)
# debouncer implementation and doesn't apply to this RTL. i_top_rst is
# still covered by the blanket set_false_path -from [get_ports i_top_rst]
# above, which is sufficient here.

#############################################################################
# NOT carried into this SDC (belong in the Genus tcl flow, not SDC):
#
# 1. set_clock_gating_style (DC-specific compile attribute). Genus
#    equivalent goes in genus_synth_ov7670.tcl before syn_opt, e.g.:
#      set_db lp_insert_clock_gating true
#      set_db lp_clock_gating_min_bitwidth 4
#      set_db lp_clock_gating_style sequential_latch
#    (exact attribute names vary by Genus version — check
#    `man set_db` / lp_* attributes for your install.)
#
# 2. compile_ultra effort flags (-gate_clock, -timing_high_effort_script)
#    — already represented in genus_synth_ov7670.tcl via
#    syn_generic_effort/syn_map_effort/syn_opt_effort = high.
#############################################################################
