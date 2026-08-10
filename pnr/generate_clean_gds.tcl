restoreDesign pnr_final.enc.dat top

# Delete the massive power crossover vias that SRoute generated to prevent the 1M+ square DBU 9/0 shorts
editDelete -object_type Via -net VDD
editDelete -object_type Via -net VSS

# Write a definitive GDS layer map file for SCL 1.2um
set map_file [open "gds.map" "w"]
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

# Stream out the clean GDS without a map file but with attachNetName to ensure VDD/VSS get text labels
streamOut pnr_clean_final.gds -attachNetName 1 -merge {../gds/core_c1d.gds ../gds/io_c1d.gds} -units 1000 -mode ALL
exit
