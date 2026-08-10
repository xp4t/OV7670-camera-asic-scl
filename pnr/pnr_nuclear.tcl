setMultiCpuUsage -localCpu 4

# Initialize design with proper global power nets
set DESIGN_NAME top
set NETLIST ../syn/sweep/E4/top_netlist.v
set LEF_FILES "../lef/tech_c1d.lef ../lef/core_c1d.lef ../lef/corner_c1d.lef ../lef/io_c1d.lef"
set MMMC_FILE ../floorplanning/mmmc.tcl

set init_verilog $NETLIST
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell $DESIGN_NAME
set init_lef_file $LEF_FILES
set init_mmmc_file $MMMC_FILE
set init_pwr_net VDD
set init_gnd_net VSS

init_design

# 2. Floorplanning (Extreme row spacing and 10% utilization)
setFPlanRowSpacingAndType 40.0 1
floorPlan -r 1.0 0.10 20.0 20.0 20.0 20.0

clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
globalNetConnect VDD -type tiehi -inst * -module {}
globalNetConnect VSS -type tielo -inst * -module {}

# 3. Power Planning
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -center 1 -stacked_via_top_layer metal2 -type core_rings -jog_distance 1.6 -threshold 1.6 -nets {VDD VSS} -follow core -stacked_via_bottom_layer metal1 -layer {bottom metal1 top metal1 right metal2 left metal2} -width 3.0 -spacing 2.0 -offset 1.0

# Route the power pins of standard cells
sroute -connect { corePin } -layerChangeRange { metal1 metal2 } -blockPinTarget { nearestTarget } -corePinTarget { ring } -allowJogging 1 -crossoverViaLayerRange { metal1 metal2 } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { metal1 metal2 }

setMultiCpuUsage -localCpu 1

# 4. Pin Assignment
set all_pins [dbGet top.terms.name]
set total [llength $all_pins]
set q [expr $total / 4]
editPin -pin [lrange $all_pins 0 [expr $q - 1]] -edge 0 -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins $q [expr 2*$q - 1]] -edge 1 -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins [expr 2*$q] [expr 3*$q - 1]] -edge 2 -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins [expr 3*$q] end] -edge 3 -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK

# 5. Placement
setPlaceMode -fp false
placeDesign

# 6. Routing
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithTimingDriven 0
setNanoRouteMode -quiet -routeWithSiDriven 0
setNanoRouteMode -quiet -routeTdrEffort 0
setNanoRouteMode -quiet -routeSiEffort 0
setNanoRouteMode -quiet -drouteEndIteration 40
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -routeTopRoutingLayer default
routeDesign -globalDetail

# 7. Add Fillers
addFiller -cell {FILLER1 FILLER2 FILLER3 FILLER4} -prefix FILL -doDRC

# 8. Signoff / Finish
saveNetlist pnr_final.v
defOut -routing pnr_final.def
saveDesign pnr_final.enc
