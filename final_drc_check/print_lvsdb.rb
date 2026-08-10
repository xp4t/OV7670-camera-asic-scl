db = RBA::NetlistCrossReference::new
db.load("lvs_report.lvsdb")

puts "Matched circuits: #{db.each_circuit.select { |c| c.is_match? }.size}"
puts "Mismatched circuits: #{db.each_circuit.select { |c| !c.is_match? }.size}"

db.each_circuit do |c|
  if !c.is_match?
    puts "Mismatch in circuit #{c.name}"
    
    nm = 0
    c.each_net_mismatch do |m|
      puts "  Net mismatch: #{m}"
      nm += 1
      break if nm > 10
    end
    
    dm = 0
    c.each_device_mismatch do |m|
      puts "  Device mismatch: #{m}"
      dm += 1
      break if dm > 10
    end
    
    pm = 0
    c.each_pin_mismatch do |m|
      puts "  Pin mismatch: #{m}"
      pm += 1
      break if pm > 10
    end
  end
end
