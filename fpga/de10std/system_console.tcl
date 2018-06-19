set master [lindex [get_service_paths master] 0]
open_service master $master

set sniffer_base 0x80000000
puts "Server started, USB Sniffer cfg: [master_read_32 $master [expr $sniffer_base + 0] 1]"

proc accept {chan saddr port} {
    global master
    puts "Client connected"
    fconfigure $chan -blocking 1 -buffering none -encoding binary -translation binary
    while {1} {
        if {![binary scan [read $chan 9] c1iu1i1 cmd addr length]} {
            break;
        }
        set offset 0
        while {$offset < $length} {
            if {$cmd == 1} {
                binary scan [read $chan 4] iu1 bytes
                master_write_32 $master [expr $addr + $offset] $bytes
            }
            if {$cmd == 2} {
                set bytes [master_read_32 $master [expr $addr + $offset] 1]
                puts -nonewline $chan [binary format iu1 $bytes]
            }
            incr offset 4
        }
    }
    close $chan

    global sniffer_base
    puts "Client disconnected, USB Sniffer cfg: [master_read_32 $master [expr $sniffer_base + 0] 1]"
}
socket -server accept 12345
vwait forever
