set log file lec.log -replace
read library -liberty ../lib/nldm_tt_27_1p5.lib ../lib/scl1u_pads_typ.lib -both
read design -verilog2k ../rtl/debouncer.v ../rtl/sccb_master.v ../rtl/cam_rom.v ../rtl/cam_init.v ../rtl/cam_config.v ../rtl/cam_capture.v ../rtl/mem_bram.v ../rtl/cam_top.v ../rtl/vga_driver.v ../rtl/vga_top.v ../rtl/top.v -golden
read design -verilog2k ../pnr/pnr_final.v -revised

set flatten model -seq_constant -gated_clock
set system mode lec
add compare points -all
compare
report verification -summary
exit -force
