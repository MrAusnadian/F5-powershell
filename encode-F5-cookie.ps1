function Encode-Cookie {
 param ([string] $ip,[int] $port)
    $encodedIP = $null

    if (($ip -match '^(\d+)\.(\d+)\.(\d+)\.(\d+)') -AND ($port -match '^(\d+)')) {
        <#
        https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html
        The BIG-IP system uses the following address encoding algorithm:

        Convert each octet value to the equivalent 1-byte hexadecimal value.
        Reverse the order of the hexadecimal bytes and concatenate to make one 4-byte hexadecimal value.
        Convert the resulting 4-byte hexadecimal value to its decimal equivalent.

        The BIG-IP system uses the following port encoding algorithm:

        Convert the decimal port value to the equivalent 2-byte hexadecimal value.
        Reverse the order of the 2 hexadecimal bytes.
        Convert the resulting 2-byte hexadecimal value to its decimal equivalent.
        #>

        $octets = $ip.Split(".")

        $encodedIP = [int]$octets[0] + ([int]$octets[1]*256) + ([int]$octets[2]*([math]::pow(256,2))) + ([int]$octets[3]*([math]::pow(256,3)))

        $hexPort = '{0:X4}' -f $port

        $hexPortSplit = $hexPort -split '(.{2})' | ? {$_}

        $counter = 0
        $hexPortReversed = $null
        while($counter -le 2) {
            $hexPortReversed = $hexPortSplit[$counter] + $hexPortReversed
            $counter++
        }

        $encodedPort = [Convert]::ToInt32($hexPortReversed,16)

        $string = "$encodedIP.$encodedPort.0000"

        return $string
    }

    else {
        write-output "cookie string format is invalid."
        write-output "usage:"
        write-output "  Encode-BigIPCookie 10.10.10.10 80"
     }
 }