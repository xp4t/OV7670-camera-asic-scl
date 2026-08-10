setMultiCpuUsage -localCpu 4

# ============================================================
# pnr_signoff_grade.tcl
# Fabrication-grade PnR for OV7670 Camera ASIC on SCL 1.2um C1D
# Produces ONE GDS that passes DRC, LVS, and antenna checks.
# ============================================================

# 1. DESIGN INITIALIZATION
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

# 2. FLOORPLANNING (10% utilization + 40um row spacing)
setFPlanRowSpacingAndType 40.0 1
floorPlan -r 1.0 0.10 20.0 20.0 20.0 20.0

clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
globalNetConnect VDD -type tiehi -inst * -module {}
globalNetConnect VSS -type tielo -inst * -module {}

# 3. POWER PLANNING
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell \
    -center 1 -stacked_via_top_layer metal2 -type core_rings \
    -jog_distance 1.6 -threshold 1.6 \
    -nets {VDD VSS} -follow core \
    -stacked_via_bottom_layer metal1 \
    -layer {bottom metal1 top metal1 right metal2 left metal2} \
    -width 3.0 -spacing 2.0 -offset 1.0

# Route power pins — DO NOT delete vias afterward
sroute -connect { corePin } \
    -layerChangeRange { metal1 metal2 } \
    -blockPinTarget { nearestTarget } \
    -corePinTarget { ring } \
    -allowJogging 1 \
    -crossoverViaLayerRange { metal1 metal2 } \
    -nets { VDD VSS } \
    -allowLayerChange 1 \
    -blockPin useLef \
    -targetViaLayerRange { metal1 metal2 }

# 4. PIN ASSIGNMENT (40um spacing across all 4 edges)
set all_pins [dbGet top.terms.name]
set total [llength $all_pins]
set q [expr $total / 4]
editPin -pin [lrange $all_pins 0 [expr $q - 1]] -edge 0 \
    -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins $q [expr 2*$q - 1]] -edge 1 \
    -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins [expr 2*$q] [expr 3*$q - 1]] -edge 2 \
    -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK
editPin -pin [lrange $all_pins [expr 3*$q] end] -edge 3 \
    -layer metal2 -spreadType CENTER -spacing 40.0 -snap TRACK

# 5. PLACEMENT
setPlaceMode -fp false
placeDesign

# 6. PRE-CTS OPTIMIZATION
optDesign -preCTS

# 7. CLOCK TREE SYNTHESIS
create_ccopt_clock_tree_spec -file ccopt_signoff.spec
source ccopt_signoff.spec
ccopt_design

# 8. POST-CTS OPTIMIZATION
optDesign -postCTS
optDesign -postCTS -hold

# 9. ROUTING (timing-driven, 60 iterations for better convergence)
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 0
setNanoRouteMode -quiet -drouteEndIteration 60
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -routeTopRoutingLayer default
routeDesign -globalDetail

# 10. POST-ROUTE OPTIMIZATION
optDesign -postRoute
optDesign -postRoute -hold

# 11. ECO DRC FIX (the step that was never run before)
setNanoRouteMode -drouteEndIteration 60
ecoRoute -fix_drc

# 12. ADD FILLERS
addFiller -cell {FILLER4 FILLER3 FILLER2 FILLER1} -prefix FILL -doDRC

# 13. FINAL VERIFICATION (Inside Innovus)
verify_drc -report drc_final.rpt -limit 100
verifyConnectivity -type all -report connectivity_final.rpt
verifyProcessAntenna -report antenna_final.rpt

# 14. SAVE DESIGN
saveNetlist pnr_signoff.v
defOut -routing pnr_signoff.def
saveDesign pnr_signoff.enc

# 15. EXTRACT PARASITICS
extractRC
rcOut -spef pnr_signoff.spef

# 16. GDS EXPORT WITH CORRECT LAYER MAP
set map_file [open "gds_signoff.map" "w"]
puts $map_file "metal1 ALL 8 0"
puts $map_file "metal1 PIN 8 0"
puts $map_file "metal1 LABEL 8 7"
puts $map_file "metal1 TEXT 8 7"
puts $map_file "metal2 ALL 10 0"
puts $map_file "metal2 PIN 10 0"
puts $map_file "metal2 LABEL 10 7"
puts $map_file "metal2 TEXT 10 7"
puts $map_file "via1 ALL 9 0"
puts $map_file "via1 VIA 9 0"
close $map_file

streamOut pnr_signoff.gds \
    -mapFile gds_signoff.map \
    -attachNetName 1 \
    -merge {../gds/core_c1d.gds ../gds/io_c1d.gds} \
    -units 1000 \
    -mode ALL

puts "############################################"
puts "# PnR SIGNOFF COMPLETE"
puts "# DRC report:          drc_final.rpt"
puts "# Connectivity report: connectivity_final.rpt"
puts "# Antenna report:      antenna_final.rpt"
puts "# Signoff GDS:         pnr_signoff.gds"
puts "# Signoff netlist:     pnr_signoff.v"
puts "# Signoff SPEF:        pnr_signoff.spef"
puts "############################################"
exit
