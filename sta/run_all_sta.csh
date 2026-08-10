#!/bin/csh
setenv SDC_FILE ../syn/sweep/E4/top_synth.sdc
setenv PT_BIN /opt/synopsys/primetime/prime/T-2022.03-SP2/bin/pt_shell

echo "Running Post-Synthesis STA..."
setenv STAGE post_synth
setenv NETLIST ../syn/sweep/E4/top_netlist.v
setenv SPEF_FILE ""
$PT_BIN -f run_pt.tcl > pt_synth.log

echo "Running Post-Floorplan STA..."
setenv STAGE post_fp
setenv NETLIST ../syn/sweep/E4/top_netlist.v
setenv SPEF_FILE ""
$PT_BIN -f run_pt.tcl > pt_fp.log

echo "Running Post-PnR STA..."
setenv STAGE post_pnr
setenv NETLIST ../pnr/pnr_final.v
setenv SPEF_FILE ../pnr/pnr_final.spef
$PT_BIN -f run_pt.tcl > pt_pnr.log

echo "STA complete for all stages!"
