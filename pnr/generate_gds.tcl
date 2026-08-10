restoreDesign pnr_final.enc.dat top
streamOut pnr_final.gds -merge {../gds/core_c1d.gds ../gds/io_c1d.gds} -units 1000 -mode ALL
exit
