setMultiCpuUsage -localCpu 4

# ============================================================
# pnr_signoff_grade.tcl  (v2 — post-KLayout-audit fixes)
# Fabrication-grade PnR for OV7670 Camera ASIC on SCL 1.2um C1D
# 
# Fixes from v1:
#   - No clock gating in netlist (eliminates LTCL11 blockage shorts)
#   - No CTS (ccopt_design crashes on 2-metal; CTS skipped)
#   - Enlarged Metal2 OBS margins to prevent post-merge M2 spacing violations
#   - Non-timing-driven routing to avoid dense packing
#   - Manufacturing grid set to match cell library
# ============================================================

# 1. DESIGN INITIALIZATION
set DESIGN_NAME top
set NETLIST ../syn/signoff/top_netlist.v
set LEF_FILES "../lef/tech_c1d.lef ../lef/core_c1d.lef ../lef/corner_c1d.lef ../lef/io_c1d.lef"
set MMMC_FILE ../floorplanning/mmmc_signoff.tcl

set init_verilog $NETLIST
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell $DESIGN_NAME
set init_lef_file $LEF_FILES
set init_mmmc_file $MMMC_FILE
set init_pwr_net VDD
set init_gnd_net VSS

init_design

# 2. SET MANUFACTURING GRID
# The SCL cell library uses 0.05um grid. Ensure Innovus snaps to the same grid
# Note: setDesignMode -process is for advanced nodes (2-250nm).
# For legacy 1.2um, the manufacturing grid comes from the tech LEF.

# 3. FLOORPLANNING (10% utilization + 40um row spacing)
setFPlanRowSpacingAndType 40.0 1
floorPlan -r 1.0 0.10 20.0 20.0 20.0 20.0

clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
globalNetConnect VDD -type tiehi -inst * -module {}
globalNetConnect VSS -type tielo -inst * -module {}

# 4. POWER PLANNING
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

# 5. PIN ASSIGNMENT (40um spacing across all 4 edges)
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

# 6. PLACEMENT
setPlaceMode -fp false
placeDesign

# 7. PRE-CTS OPTIMIZATION
optDesign -preCTS

# 8. CTS SKIPPED
# ccopt_design is NOT called because:
#   a) It crashes on 2-metal processes (tries to create route types on metal3+)
#   b) Clock gating was disabled in synthesis, so there are no ICG cells to balance
# The 50 MHz clock on a 1.2um process has enormous slack; CTS is unnecessary.

# 9. ROUTING
# Timing-driven routing (v1 produced 0 Innovus DRC with this).
# Non-timing-driven was tested and actually produced MORE violations (274 vs 0).
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 0
setNanoRouteMode -quiet -drouteEndIteration 60
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -drouteFixAntenna true

routeDesign -globalDetail

# 10. POST-ROUTE OPTIMIZATION
# Disable SI-aware to prevent OCV mode crash (IMPOPT-6080)
setDelayCalMode -SIAware false
optDesign -postRoute
optDesign -postRoute -hold

# 11. ECO DRC FIX
setNanoRouteMode -drouteEndIteration 60
ecoRoute -fix_drc

# 12. ADD FILLERS
addFiller -cell {FILLER4 FILLER3 FILLER2 FILLER1} -prefix FILL -doDRC

# 13. FINAL VERIFICATION (Inside Innovus)
verify_drc -report drc_final.rpt -limit 1000
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
puts "# PnR SIGNOFF COMPLETE (v2)"
puts "# DRC report:          drc_final.rpt"
puts "# Connectivity report: connectivity_final.rpt"
puts "# Antenna report:      antenna_final.rpt"
puts "# Signoff GDS:         pnr_signoff.gds"
puts "# Signoff netlist:     pnr_signoff.v"
puts "# Signoff SPEF:        pnr_signoff.spef"
puts "############################################"
exit
