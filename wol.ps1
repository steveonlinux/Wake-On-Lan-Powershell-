<#
Name: Stephen Marks
Component Name: Wake On Lan Specified Device (Node Not Required)
Description: Will send WOL packet to specified device via ip or hostname.
Designed for use with RMM that allows users to define variables ultimately via
environmental variables. Default values are "undefined" and "false". Retains some portability.
Date: 10/17/21
#>

function generate_packet {
	if ( $env:mac_addr -eq "undefined" ) {
		echo "No MAC Address given. Exiting"
		exit
	}
	$mac_array = $env:mac_addr -split "[:-]" | ForEach-Object { "0x$_" } #Splits into substrings defined by delim and appends hex indentifier
	[Byte[]] $global:magic_packet = (,0xFF * 6) + ($mac_array  * 16) #Generates 2d hex array - "magic packet"
	$global:udp_client = new-object system.net.sockets.udpclient
}
function connect_device { #Connects to device via IP or hostname via UDP over port $env:port.
	if ( ( $env:ip_addr -ne "undefined" ) -or ( ( $env:ip_addr -and $env:host_name ) -ne "undefined" ) ) { # If ip or both ip and host are provided
		$udp_client.connect(([System.Net.IPAddress]$env:ip_addr),[int]$env:port) #WOL typically uses UDP over ports 7, 9, and sometimes 0.
	}
	elseif ($env:host_name -ne "undefined" ) {
			$udp_client.connect(($env:host_name),[int]$env:port)
	}
	else {
		echo "No device given. Exiting"
		exit
	}
}
function send_packet { #Sends packet via specified port
	$udp_client.send($magic_packet,$magic_packet.length) > $null
	$udp_client.close()
}
function generate_stdout {
	if ( $env:host_name -ne "undefined" ) {
		echo ( "The device named " + $env:host_name + " has been sent the Wake on Lan packet." )
	}
	elseif ( $env:ip_addr -ne "undefined" ) {
		echo ( "The device of IP address " + $env:ip_addr + " has been sent the Wake on Lan packet." )
	}
}
generate_packet
connect_device
send_packet
generate_stdout
