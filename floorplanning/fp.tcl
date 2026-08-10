set DESIGN_NAME top
set NETLIST ../syn/sweep/E4/top_netlist.v
set LEF_FILES "../lef/tech_c1d.lef ../lef/core_c1d.lef ../lef/corner_c1d.lef ../lef/io_c1d.lef"
set MMMC_FILE mmmc.tcl

set init_verilog $NETLIST
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell $DESIGN_NAME
set init_lef_file $LEF_FILES
set init_mmmc_file $MMMC_FILE

# Initialize Design
init_design

# Floorplanning:
# Aspect ratio 1.0 (square), core utilization 70% (0.7), and 20um core margins
floorPlan -r 1.0 0.7 20 20 20 20



# Save floorplanned design database
saveDesign fp.enc

puts "############################################"
puts "# Innovus floorplanning completed for $DESIGN_NAME"
puts "############################################"
exit
