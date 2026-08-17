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
set LEF_FILES "../lef/tech_c1d.lef ../lef/core_c1d_signoff.lef ../lef/corner_c1d.lef ../lef/io_c1d.lef"
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

# Match the synthesis dont-use list. optDesign/ecoRoute can otherwise
# re-introduce cells that violate SCL C1D rules in isolation.
foreach cell_name {AOI401 NND300 NND501 NOR701 OR3101 ORND01 DFPC11 LTPR11} {
    setDontUse $cell_name true
}

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

# Force every inter-cell gap to be either 0 or >= 6.0um, via 3.0um (300 SITEs of
# 0.01um) of padding on each side of every non-filler cell.
#
# Filler boron sits at cell y 24.55..48.7 and filler nwell at 23.7..48.7, but the
# logic cells put boron and nwell in different vertical bands (INVR01 boron
# 1.65..41.25, AND201 2.30..43.15, DFCL11 1.20..46.50). Where a filler abuts a
# logic cell their bands do not line up, so the filler side protrudes as a
# vertical finger whose width is the width of the filler run. A run narrower than
# 2.5um then fails 5.1.1 (boron width) and, at run + 1.5um of nwell overhang
# narrower than 4.0um, fails 1.1.1 (nwell width). 300 SITEs also sets the
# filler run at each row end, which is bounded by the padding rather than by a
# neighbour -- at 200 that run was 2.0um and produced the only remaining width
# violations, measured at exactly 2.20um of boron and 3.50um of nwell.
#
# So filling every gap is not enough on its own: filling a sub-2.5um gap only
# trades a 5.7.1 spacing violation for a 5.1.1 width violation. Measured proof --
# nwell violations of exactly 3.73um and 3.02um, i.e. filler runs of 2.23um and
# 1.52um. A 3.0um-per-side floor makes the narrowest possible finger 3.0um of
# boron and 4.5um of nwell.
#
# Cell padding rather than -place_detail_legalization_inst_gap: that option caps
# out well below what is needed here and Innovus silently discards it
# ("IMPSP-2036: Ignoring ... value of 400 ... as the value is too large").
# Fillers are never padded -- they must abut to keep the implant strip continuous.
foreach lib_cell [dbGet -u head.libCells.name] {
    if {[regexp {^FILLER} $lib_cell]} { continue }
    catch {specifyCellPad $lib_cell -left 300 -right 300}
}
reportCellPad > cellpad.rpt

placeDesign

# 7. PRE-CTS OPTIMIZATION
optDesign -preCTS

# 8. CTS SKIPPED
# ccopt_design is NOT called because:
#   a) It crashes on 2-metal processes (tries to create route types on metal3+)
#   b) Clock gating was disabled in synthesis, so there are no ICG cells to balance
# The 50 MHz clock on a 1.2um process has enormous slack; CTS is unnecessary.

# 9. ROUTING
# Timing-driven routing pulls the AAE delay engine into the routing loop, and it
# crashes there on this design ("Crashed in AAE on net Unknown net", inside
# goOptFlow::Config::routeDesign). A 50 MHz clock on a 1.2um process has enormous
# slack, so timing-driven routing buys nothing worth that risk.
setDelayCalMode -SIAware false
setNanoRouteMode -quiet -routeWithTimingDriven 0
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
# FILLER5 is mandatory, not optional. SITE CORE is 0.01um wide, so placement
# leaves gaps at arbitrary 0.01um multiples (measured: 3981 gaps, 2451 of them
# under 1um -- 0.06, 0.11, 0.22, 0.45, 0.88um ...). FILLER1-4 are 8/4/2/1um and
# cannot tile those remainders. Logic cells have zero boron overhang, so any
# residual gap breaks the P+ implant strip and produces 5.7.1 boron-spacing
# violations; an isolated FILLER3/FILLER4 also fails 5.1.1 boron width (its
# boron is only 2.2/1.2um) and 1.1.1 nwell width. FILLER5 is 0.01um = exactly
# one site, which closes every remainder and makes each row one continuous
# implant strip.
# Two passes: the coarse fillers DRC-aware, then FILLER5 to close the residue.
# Keeping FILLER5 out of the -doDRC pass matters -- roughly 187k of them are
# needed, and DRC-checking each one is far slower than the fill itself.
# -fitGap picks filler combinations that avoid leaving single-site gaps.
addFiller -cell {FILLER1 FILLER2 FILLER3 FILLER4} -prefix FILL -doDRC -fitGap
addFiller -cell {FILLER5} -prefix FILLRES

# 13. FINAL VERIFICATION (Inside Innovus)
verify_drc -report drc_final.rpt -limit 1000
verifyConnectivity -type all -report connectivity_final.rpt
verifyProcessAntenna -report antenna_final.rpt

# 14. SAVE DESIGN
# -includePowerGround: LVS needs VDD/VSS on every instance. Without it the
# SPICE conversion leaves those pins dangling as _NC nets.
saveNetlist pnr_signoff.v -includePowerGround
saveNetlist pnr_signoff_flat.v -includePowerGround -flat
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
    -merge {../gds/core_c1d_signoff.gds ../gds/io_c1d.gds} \
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
