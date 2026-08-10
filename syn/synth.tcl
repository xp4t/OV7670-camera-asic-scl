#############################################################################
# Genus RTL-to-Gate Synthesis Script
# Project : OV7670 Camera -> VGA ASIC
# PDK     : SCL 1.2um Digital (C1D) Open Source Kit
# Tool    : Cadence Genus
#
# Assumes this script is run from a 'syn/' subfolder of the project root,
# i.e. the layout is:
#
#   <project>/rtl/*.v
#   <project>/lef/*.lef
#   <project>/lib/*.lib
#   <project>/constraints.sdc  <- YOU MUST CREATE/EDIT THIS (template provided)
#   <project>/syn/genus_synth_ov7670.tcl   <- run genus from inside here
#
# NOTE: mem_bram.v is assumed to be synthesizable RTL (not a hard macro).
# If it instantiates a compiled SRAM macro, you need that macro's own
# .lib/.lef/.gds and this script must read_libs / read_physical those too,
# plus set_db lp_insert_clock_gating false on the macro boundary as needed.
#############################################################################

set DESIGN_NAME      "top"
set RTL_ROOT         "../rtl"
set LIB_ROOT         "../lib"
set LEF_ROOT         "../lef"
set OUT_DIR          "../out"
set REPORT_DIR       "../reports"
set CONSTRAINTS_FILE "../constraints.sdc"

file mkdir $OUT_DIR
file mkdir $REPORT_DIR

#############################################################################
# 1. Library setup — Multi-Corner (tt func / ss worst-setup / ff worst-hold)
#############################################################################
set LIB_TT "$LIB_ROOT/nldm_tt_27_1p5.lib"
set LIB_SS "$LIB_ROOT/nldm_ss_125_2p45.lib"
set LIB_FF "$LIB_ROOT/nldm_ff_m25_1p55.lib"

# IO pad libs (typ/min/max) — included alongside core libs per corner.
set PAD_TYP "$LIB_ROOT/scl1u_pads_typ.lib"
set PAD_MIN "$LIB_ROOT/scl1u_pads_min.lib"
set PAD_MAX "$LIB_ROOT/scl1u_pads_max.lib"

set_db init_lib_search_path $LIB_ROOT
set_db init_hdl_search_path $RTL_ROOT

# Library sets per corner (core + matching pad lib)
# NOTE: define_library_set / define_delay_corner / define_constraint_mode /
# define_analysis_view do NOT exist as Genus commands -- that was the
# "unknown command" error. The correct MMMC verb in Genus is create_*, not
# define_* (define_* is a Design Compiler-ism, carried over by mistake
# from the SAED32/DC background of this project). Fixed below.
create_library_set -name LS_TT -timing [list $LIB_TT $PAD_TYP]
create_library_set -name LS_SS -timing [list $LIB_SS $PAD_MAX]
create_library_set -name LS_FF -timing [list $LIB_FF $PAD_MIN]

# create_delay_corner has NO -library_set flag (verified against the
# verbose command usage) -- a library_set must be wrapped in a
# timing_condition first, then the delay_corner references the
# timing_condition. This bridge step was missing before.
create_timing_condition -name TC_TT -library_sets LS_TT
create_timing_condition -name TC_SS -library_sets LS_SS
create_timing_condition -name TC_FF -library_sets LS_FF

# No QRC/captable available from this kit — using default wireload model
# embedded in the .lib files. Add -rc_corner <name> here once you have a
# real captable, for signoff-accurate parasitics.
create_delay_corner -name DC_TT -timing_condition TC_TT
create_delay_corner -name DC_SS -timing_condition TC_SS
create_delay_corner -name DC_FF -timing_condition TC_FF

create_constraint_mode -name CM_FUNC -sdc_files [list $CONSTRAINTS_FILE]

create_analysis_view -name AV_SETUP_SS -constraint_mode CM_FUNC -delay_corner DC_SS
create_analysis_view -name AV_HOLD_FF  -constraint_mode CM_FUNC -delay_corner DC_FF
create_analysis_view -name AV_FUNC_TT  -constraint_mode CM_FUNC -delay_corner DC_TT

set_analysis_view -setup { AV_SETUP_SS } -hold { AV_HOLD_FF }

#############################################################################
# 2. Physical data (LEF) — for iSpatial / physical-aware synthesis
#############################################################################
read_physical -lefs [list \
    $LEF_ROOT/tech_c1d.lef \
    $LEF_ROOT/core_c1d.lef \
    $LEF_ROOT/corner_c1d.lef \
    $LEF_ROOT/io_c1d.lef \
]

#############################################################################
# 3. Read RTL
#############################################################################
read_hdl [list \
    $RTL_ROOT/debouncer.v      \
    $RTL_ROOT/sccb_master.v    \
    $RTL_ROOT/cam_rom.v        \
    $RTL_ROOT/cam_init.v       \
    $RTL_ROOT/cam_config.v     \
    $RTL_ROOT/cam_capture.v    \
    $RTL_ROOT/mem_bram.v       \
    $RTL_ROOT/cam_top.v        \
    $RTL_ROOT/vga_driver.v     \
    $RTL_ROOT/vga_top.v        \
    $RTL_ROOT/top.v            \
]

elaborate $DESIGN_NAME
current_design $DESIGN_NAME

check_design -unresolved
uniquify $DESIGN_NAME

#############################################################################
# 4. Constraints
#############################################################################
# CORRECTION: an earlier version of this script omitted read_sdc, on the
# (wrong) assumption that create_constraint_mode -sdc_files auto-loads the
# file once set_analysis_view activates. The actual run log proved this
# false -- "Cost Group 'default' target slack: Unconstrained" during
# syn_generic/syn_map showed the SDC was never read, which is why the
# .rpt files came back empty/trivial. -sdc_files only *registers* the
# filename against the constraint_mode for bookkeeping; read_sdc is the
# real read command, and it must be scoped per active view with -view.
# -view scoping removed: -echo output on a prior run showed the crash
# happens BEFORE any SDC line is even read, i.e. Genus fails while
# resolving the -view AV_SETUP_SS argument itself (Failed on assert(
# {[llength $mode]})), not on anything inside constraints.sdc. This is
# despite create_analysis_view -constraint_mode CM_FUNC having succeeded
# earlier in the same run -- looks like a tool-side inconsistency on this
# (very old, 1503-day) Genus build rather than a script/SDC content bug.
# Falling back to unscoped read_sdc, which applies against whatever
# set_analysis_view already made active (AV_SETUP_SS for setup,
# AV_HOLD_FF for hold).
# -view removed permanently: confirmed root cause of the earlier crash
# (Failed on assert({[llength $mode]})) via -echo diagnostic -- this
# build of Genus (21.14-s082_1, 1503 days old) has a bug/inconsistency
# in -view argument resolution for read_sdc even when the analysis view
# was created cleanly moments earlier in the same session. Unscoped
# read_sdc against the already-active setup/hold views (via
# set_analysis_view above) works correctly instead.
read_sdc $CONSTRAINTS_FILE

#############################################################################
# 5. Synthesis effort / strategy
#############################################################################
set_db syn_generic_effort   high
set_db syn_map_effort       high
set_db syn_opt_effort       high
set_db information_level    7

# Keep hierarchy off top-level cam/vga blocks initially for easier debug;
# flatten later if needed for final QoR.
set_db auto_ungroup none

#############################################################################
# 6. Run synthesis
#############################################################################
syn_generic
syn_map
syn_opt -incremental

#############################################################################
# 7. Reports (pre-signoff QoR)
#############################################################################
report_timing -unconstrained                  > $REPORT_DIR/timing_unconstrained.rpt
report_timing                                 > $REPORT_DIR/timing_worst.rpt
report_area                                   > $REPORT_DIR/area.rpt
report_power                                  > $REPORT_DIR/power.rpt
report_gates                                  > $REPORT_DIR/gates.rpt
report_dp                                     > $REPORT_DIR/datapath.rpt
check_timing_intent                           > $REPORT_DIR/timing_intent.rpt

# DRC-type violations (max transition / max cap / max fanout)
report_ple > $REPORT_DIR/design_rule_violations.rpt

#############################################################################
# 8. Write outputs for Innovus handoff
#############################################################################
write_netlist                     > $OUT_DIR/${DESIGN_NAME}_netlist.v
write_sdc                         > $OUT_DIR/${DESIGN_NAME}_synth.sdc
write_db  -design $DESIGN_NAME    $OUT_DIR/${DESIGN_NAME}_synth.db

# Optional: direct Innovus handoff package
# write_design -innovus -base_name $OUT_DIR/${DESIGN_NAME}_handoff

puts "############################################"
puts "# Genus synthesis complete for $DESIGN_NAME"
puts "# Reports  : $REPORT_DIR"
puts "# Netlist  : $OUT_DIR/${DESIGN_NAME}_netlist.v"
puts "############################################"