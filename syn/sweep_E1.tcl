#############################################################################
# PPA Sweep — E1: High Effort + Full Flatten (50 MHz)
# Strategy: Flatten all hierarchy for maximum cross-boundary optimization.
#############################################################################
set EXPERIMENT    "E1_higheffort_flatten"
set DESIGN_NAME   "top"
set RTL_ROOT      "../rtl"
set LIB_ROOT      "../lib"
set LEF_ROOT      "../lef"
set OUT_DIR       "sweep/E1"
set REPORT_DIR    "sweep/E1"
set CONSTRAINTS_FILE "../constraints.sdc"
file mkdir $OUT_DIR

set LIB_TT "$LIB_ROOT/nldm_tt_27_1p5.lib"
set LIB_SS "$LIB_ROOT/nldm_ss_125_2p45.lib"
set LIB_FF "$LIB_ROOT/nldm_ff_m25_1p55.lib"
set PAD_TYP "$LIB_ROOT/scl1u_pads_typ.lib"
set PAD_MIN "$LIB_ROOT/scl1u_pads_min.lib"
set PAD_MAX "$LIB_ROOT/scl1u_pads_max.lib"
set_db init_lib_search_path $LIB_ROOT
set_db init_hdl_search_path $RTL_ROOT
create_library_set -name LS_TT -timing [list $LIB_TT $PAD_TYP]
create_library_set -name LS_SS -timing [list $LIB_SS $PAD_MAX]
create_library_set -name LS_FF -timing [list $LIB_FF $PAD_MIN]
create_timing_condition -name TC_TT -library_sets LS_TT
create_timing_condition -name TC_SS -library_sets LS_SS
create_timing_condition -name TC_FF -library_sets LS_FF
create_delay_corner -name DC_TT -timing_condition TC_TT
create_delay_corner -name DC_SS -timing_condition TC_SS
create_delay_corner -name DC_FF -timing_condition TC_FF
create_constraint_mode -name CM_FUNC -sdc_files [list $CONSTRAINTS_FILE]
create_analysis_view -name AV_SETUP_SS -constraint_mode CM_FUNC -delay_corner DC_SS
create_analysis_view -name AV_HOLD_FF  -constraint_mode CM_FUNC -delay_corner DC_FF
set_analysis_view -setup { AV_SETUP_SS } -hold { AV_HOLD_FF }
read_physical -lefs [list \
    $LEF_ROOT/tech_c1d.lef \
    $LEF_ROOT/core_c1d.lef \
    $LEF_ROOT/corner_c1d.lef \
    $LEF_ROOT/io_c1d.lef ]
read_hdl [list \
    $RTL_ROOT/debouncer.v $RTL_ROOT/sccb_master.v $RTL_ROOT/cam_rom.v \
    $RTL_ROOT/cam_init.v  $RTL_ROOT/cam_config.v  $RTL_ROOT/cam_capture.v \
    $RTL_ROOT/mem_bram.v  $RTL_ROOT/cam_top.v     $RTL_ROOT/vga_driver.v \
    $RTL_ROOT/vga_top.v   $RTL_ROOT/top.v ]
elaborate $DESIGN_NAME
current_design $DESIGN_NAME
check_design -unresolved
uniquify $DESIGN_NAME
read_sdc $CONSTRAINTS_FILE
# E1: high effort + flatten
set_db syn_generic_effort   high
set_db syn_map_effort       high
set_db syn_opt_effort       high
set_db information_level    7
set_db auto_ungroup         none
ungroup -all -flatten
syn_generic
syn_map
syn_opt -incremental
report_timing -unconstrained > $REPORT_DIR/timing_unconstrained.rpt
report_timing                > $REPORT_DIR/timing_worst.rpt
report_area                  > $REPORT_DIR/area.rpt
report_power                 > $REPORT_DIR/power.rpt
report_gates                 > $REPORT_DIR/gates.rpt
write_netlist > $OUT_DIR/${DESIGN_NAME}_netlist.v
write_sdc     > $OUT_DIR/${DESIGN_NAME}_synth.sdc
puts "### $EXPERIMENT DONE ###"
