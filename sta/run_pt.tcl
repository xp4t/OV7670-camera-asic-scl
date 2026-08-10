set search_path [list ../lib]
set target_library [list nldm_tt_27_1p5.lib scl1u_pads_typ.lib]
set link_library [list * nldm_tt_27_1p5.lib scl1u_pads_typ.lib]

# Read the Netlist
read_verilog $env(NETLIST)
current_design top
link

# Read constraints
source -echo -verbose $env(SDC_FILE)

# Read parasitics if this is a post-route or post-floorplan run with SPEF
if {[info exists env(SPEF_FILE)] && $env(SPEF_FILE) != ""} {
    read_parasitics $env(SPEF_FILE)
}

# Update timing and check setup/hold
update_timing
check_timing

# Generate Reports
report_timing -delay_type max > $env(STAGE)_setup.rpt
report_timing -delay_type min > $env(STAGE)_hold.rpt
report_qor > $env(STAGE)_qor.rpt
report_constraints -all_violators > $env(STAGE)_violators.rpt

exit
