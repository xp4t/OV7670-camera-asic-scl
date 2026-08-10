# Load design
restoreDesign pnr_final.enc.dat top
# Report DRC
verify_drc -report drc.rpt -limit 50
