#############################################################################
# Fabrication-Grade Synthesis — NO Clock Gating
# Based on sweep_E4.tcl but with clock gating DISABLED to eliminate
# the LTCL11 enl_reg cell blockage violations that cause unresolvable
# DRC shorts on the 2-layer metal SCL 1.2um C1D process.
#############################################################################
set DESIGN_NAME   "top"
set RTL_ROOT      "../rtl"
set LIB_ROOT      "../lib"
set LEF_ROOT      "../lef"
set OUT_DIR       "signoff"
set REPORT_DIR    "signoff"
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
    $LEF_ROOT/core_c1d_signoff.lef \
    $LEF_ROOT/corner_c1d.lef \
    $LEF_ROOT/io_c1d.lef ]

# ---------------------------------------------------------------------------
# Exclude library cells that violate SCL C1D design rules in isolation.
# Verified by running the c1d_digital.drc rules on each cell of core_c1d.gds
# standalone: these fail with no design geometry around them, so no placement
# or routing choice can clean them up.
#   9.4.1 via-to-poly spacing < 1.2um : AOI401 NND300 NND501 NOR701 OR3101 ORND01
#   5.5.1 boron-to-Ndiff spacing < 0.7um : DFPC11 LTPR11
# ---------------------------------------------------------------------------
set DRC_DIRTY_CELLS {AOI401 NND300 NND501 NOR701 OR3101 ORND01 DFPC11 LTPR11}
foreach cell_name $DRC_DIRTY_CELLS {
    set lcs [get_db lib_cells -if ".base_name == $cell_name"]
    if {[llength $lcs] == 0} {
        puts "WARNING: dont-use cell $cell_name not found in library"
        continue
    }
    foreach lc $lcs { set_db $lc .avoid true }
    puts "dont_use: $cell_name ([llength $lcs] lib cell(s))"
}
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

# HIGH EFFORT synthesis — NO CLOCK GATING
# Clock gating with LTCL11 latches causes unresolvable DRC shorts
# on the 2-layer metal process (enl_reg cell blockage conflicts).
# Trade-off: slightly higher dynamic power, but 0 DRC violations.
set_db syn_generic_effort        high
set_db syn_map_effort            high
set_db syn_opt_effort            high
set_db information_level         7
set_db auto_ungroup              none
set_db lp_insert_clock_gating    false

syn_generic
syn_map
syn_opt -incremental

# Reports
report_timing -unconstrained           > $REPORT_DIR/timing_unconstrained.rpt
report_timing                          > $REPORT_DIR/timing_worst.rpt
report_area                            > $REPORT_DIR/area.rpt
report_power                           > $REPORT_DIR/power.rpt
report_gates                           > $REPORT_DIR/gates.rpt

# Write outputs
write_netlist > $OUT_DIR/${DESIGN_NAME}_netlist.v
write_sdc     > $OUT_DIR/${DESIGN_NAME}_synth.sdc

puts "############################################"
puts "# Signoff synthesis DONE (no clock gating)"
puts "# Netlist: $OUT_DIR/${DESIGN_NAME}_netlist.v"
puts "############################################"
exit
