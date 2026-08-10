set fp [open "commands.txt" r]

while {[gets $fp cmd] >= 0} {
    set cmd [string trim $cmd]
    if {$cmd eq ""} continue

    puts "\n===== $cmd ====="

    if {[catch {eval "$cmd -help"} err]} {
        puts "ERROR: $err"
    }
}

close $fp