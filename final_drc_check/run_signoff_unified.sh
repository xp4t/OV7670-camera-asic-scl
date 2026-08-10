#!/bin/bash
# run_signoff_unified.sh
# Runs DRC AND LVS on the SAME GDS file.
# No separate files, no hardcoded pass — real results only.

GDS_FILE=pnr_signoff.gds
SPICE_FILE=pnr_final_yosys_wrapped.spi

exec > signoff_log.txt 2>&1

echo "=========================================="
echo "  UNIFIED SIGNOFF: DRC + LVS"
echo "  GDS: $GDS_FILE"
echo "  Date: $(date)"
echo "=========================================="

echo ""
echo "--- Step 1: DRC ---"
klayout -b -r c1d_digital.drc \
    -rd input=$GDS_FILE \
    -rd top_cell=top \
    -rd report1=drc_signoff.lyrdb
echo "DRC Complete. Report: drc_signoff.lyrdb"

echo ""
echo "--- Step 2: LVS ---"
klayout -b -r lvs_os_scl_c1d.lvs \
    -rd input=$GDS_FILE \
    -rd top_cell=top \
    -rd schematic1=$SPICE_FILE \
    -rd target_netlist1=layout_extracted_signoff.cir \
    -rd report=lvs_signoff.lvsdb
echo "LVS Complete. Report: lvs_signoff.lvsdb"

echo ""
echo "=========================================="
echo "  SIGNOFF COMPLETE"
echo "  Inspect drc_signoff.lyrdb and"
echo "  lvs_signoff.lvsdb in KLayout GUI."
echo "=========================================="
