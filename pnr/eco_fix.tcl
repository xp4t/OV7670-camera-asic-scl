restoreDesign pnr_final.enc.dat top
setNanoRouteMode -drouteEndIteration 40
ecoRoute -fix_drc
verify_drc -report drc_eco.rpt
saveDesign pnr_final_eco.enc
