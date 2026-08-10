#!/bin/bash
# run_signoff.sh
# Master execution script to run KLayout DRC and LVS checks natively in batch mode.
exec > log.txt 2>&1
echo "========================================"
echo "    Running SCL 1.2um DRC Checks...     "
echo "========================================"
klayout -b -r c1d_digital.drc -rd input=pnr_clean_final.gds -rd top_cell=top -rd report1=drc_report.lyrdb
echo "DRC Complete. Report saved to drc_report.lyrdb"

echo "========================================"
echo "    Running SCL 1.2um LVS Checks...     "
echo "========================================"
# NOTE: To ignore physical filler cells during extraction and achieve a perfect flat match,
# ensure 'blank_circuit("FILLER*")' is added to your lvs_os_scl_c1d.lvs rules file if running flat.
klayout -b -r lvs_os_scl_c1d.lvs -rd input=pnr_fixed_final.gds -rd top_cell=top -rd schematic1=pnr_final_yosys_wrapped.spi -rd target_netlist1=layout_extracted.cir -rd report=lvs_report.lvsdb
echo "LVS Complete. Report saved to lvs_report.lvsdb"

echo "Done! You can open the .lyrdb and .lvsdb files in the KLayout GUI to inspect."
git add .
git commit -m "newresults"
git push
