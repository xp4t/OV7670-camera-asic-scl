#!/bin/csh -f
#############################################################################
# run_flow.csh -- Genus synthesis -> Innovus PnR -> KLayout signoff DRC/LVS
#
# Run from the repository root:   ./run_flow.csh [syn|pnr|drc|all]
#############################################################################

set STAGE = "all"
if ( $#argv > 0 ) set STAGE = "$1"

source /opt/cadence/cshrc

set ROOT = `pwd`
set LOG  = $ROOT/flow_logs
mkdir -p $LOG

# Confidential SCL decks (.drc/.lvs/.cdl) are not in this repository.
if ( ! $?PDK_PRIVATE ) set PDK_PRIVATE = /home/rithwik/final_drc_check_private

echo "=========================================================="
echo "  OV7670 ASIC flow -- stage: $STAGE"
echo "  started: `date`"
echo "=========================================================="

# ---------------------------------------------------------------- LEF rebuild
if ( "$STAGE" == "all" || "$STAGE" == "lef" ) then
    echo ""
    echo "--- Stage 0: regenerate LEF obstructions from cell GDS ---"
    cd $ROOT
    python3.11 scripts/gen_signoff_lef.py lef/core_c1d.lef gds/core_c1d.gds \
        lef/core_c1d_signoff.lef |& tee $LOG/lef_gen.log
    if ( $status != 0 ) then
        echo "ERROR: LEF generation failed"
        exit 1
    endif

    echo ""
    echo "--- Stage 0b: trim filler boron overhang ---"
    python3.11 scripts/trim_filler_boron.py gds/core_c1d.gds lef/core_c1d.lef \
        gds/core_c1d_signoff.gds |& tee $LOG/filler_trim.log
    if ( $status != 0 ) then
        echo "ERROR: filler trim failed"
        exit 1
    endif
    cd $ROOT
endif

# ---------------------------------------------------------------- synthesis
if ( "$STAGE" == "all" || "$STAGE" == "syn" ) then
    echo ""
    echo "--- Stage 1: Genus synthesis ---"
    cd $ROOT/syn
    genus -no_gui -files synth_signoff.tcl |& tee $LOG/genus.log
    if ( ! -f signoff/top_netlist.v ) then
        echo "ERROR: synthesis produced no netlist"
        exit 1
    endif
    cd $ROOT
endif

# ---------------------------------------------------------------- place/route
if ( "$STAGE" == "all" || "$STAGE" == "pnr" ) then
    echo ""
    echo "--- Stage 2: Innovus place and route ---"
    cd $ROOT/pnr
    innovus -no_gui -files pnr_signoff_grade.tcl |& tee $LOG/innovus.log
    if ( ! -f pnr_signoff.gds ) then
        echo "ERROR: PnR produced no GDS"
        exit 1
    endif
    echo ""
    echo "Innovus verify_drc:"
    cat drc_final.rpt
    cd $ROOT

    echo ""
    echo "--- Stage 2b: regenerate the derived nwell_rev mask ---"
    python3.11 scripts/regen_nwell_rev.py pnr/pnr_signoff.gds \
        pnr/pnr_signoff_final.gds top |& tee $LOG/nwell_rev.log
    if ( $status != 0 ) then
        echo "ERROR: nwell_rev regeneration failed"
        exit 1
    endif
endif

# ---------------------------------------------------------------- signoff DRC
# The vendor deck is the authority. scripts/klayout points at a local 0.28.17
# build because the PDK's .deb needs glibc 2.34 and this host has 2.28.
# scripts/drc_check.py is a ~10s Python pre-check for iterating; it is not signoff.
if ( "$STAGE" == "all" || "$STAGE" == "drc" ) then
    echo ""
    echo "--- Stage 3: signoff DRC (vendor deck) ---"
    cd $ROOT
    if ( ! -f "$PDK_PRIVATE/c1d_digital.drc" ) then
        echo "ERROR: DRC deck not found at $PDK_PRIVATE/c1d_digital.drc"
        echo "       set PDK_PRIVATE to the directory holding the SCL decks"
        exit 1
    endif
    ./scripts/klayout -b -r $PDK_PRIVATE/c1d_digital.drc \
        -rd input=$ROOT/pnr/pnr_signoff_final.gds \
        -rd top_cell=top \
        -rd report1=$ROOT/pnr/drc_signoff.lyrdb |& tee $LOG/klayout_drc.log
    echo ""
    echo "violations by rule:"
    grep -o '<category>[^<]*</category>' $ROOT/pnr/drc_signoff.lyrdb \
        | sort | uniq -c | sort -rn
    echo -n "TOTAL violations: "
    grep -c '<item>' $ROOT/pnr/drc_signoff.lyrdb
endif

echo ""
echo "=========================================================="
echo "  flow finished: `date`"
echo "  logs in $LOG"
echo "=========================================================="
