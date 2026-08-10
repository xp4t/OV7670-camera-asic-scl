#!/bin/bash
# Collect PPA results from all sweep experiments and print a comparison table
echo "======================================================================="
echo " PPA Sweep Results — OV7670 ASIC (SCL 1.2um)"
echo "======================================================================="
printf "%-28s %-12s %-14s %-14s %-10s\n" "Experiment" "Cells" "Area(um2)" "Power(W)" "WNS(ps)"
echo "-----------------------------------------------------------------------"

for EXP in E1 E2 E3 E4 E5; do
    DIR="sweep/$EXP"
    AREA_RPT="$DIR/area.rpt"
    PWR_RPT="$DIR/power.rpt"
    TIM_RPT="$DIR/timing_worst.rpt"

    # Cell count and area from area.rpt (line with "top ")
    CELLS=$(grep -m1 "^top " "$AREA_RPT" 2>/dev/null | awk '{print $3}')
    AREA=$(grep  -m1 "^top " "$AREA_RPT" 2>/dev/null | awk '{print $4}')
    [ -z "$CELLS" ] && CELLS="N/A"
    [ -z "$AREA"  ] && AREA="N/A"

    # Total power from power.rpt (Subtotal line)
    POWER=$(grep "Subtotal" "$PWR_RPT" 2>/dev/null | awk '{print $5}')
    [ -z "$POWER" ] && POWER="N/A"

    # Worst slack from timing_worst.rpt
    WNS=$(grep "Slack:=" "$TIM_RPT" 2>/dev/null | head -1 | awk '{print $NF}')
    [ -z "$WNS" ] && WNS="N/A"

    # Experiment name from TCL script
    NAME=$(grep "^set EXPERIMENT" "sweep_${EXP}.tcl" 2>/dev/null | awk -F'"' '{print $2}')
    [ -z "$NAME" ] && NAME="$EXP"

    printf "%-28s %-12s %-14s %-14s %-10s\n" "$NAME" "$CELLS" "$AREA" "$POWER" "$WNS"
done

echo "======================================================================="
echo "Baseline (synth.tcl run #4): 3039 cells, 4176298 um2, 0.287 W, 0 ps WNS"
echo "======================================================================="
