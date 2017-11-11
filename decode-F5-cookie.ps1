# Decode-BigIPCookie.ps1
# usage:
# Decode-BigIPCookie "375537930.544.0000"
function Decode-Cookie {
param ([string] $ByteArrayCookie)
  ### F5 itself for the formula: http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html
  ### $poolcookie="375537930.544.0000"
  ###

  if ($ByteArrayCookie -match '^(\d+)\.(\d+)\.0000$') {
    $ipEncoded   = [int64] $matches[1]
    $portEncoded = [int64] $matches[2]

    #  convert ipEnc to Hexadecimal
    $ipEncodedHex = "{0:X8}" -f $ipEncoded
    #  then split into an array of four
    $ByteArray=@()
    $ipEncodedHex -split '([a-f0-9]{2})' | ForEach-Object {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}
    #  now reverse the array (the byte order)
    $ReversedBytes = -join ($ByteArray[$($ByteArray.Length-1)..0])
    #  and convert each 1-byte hex back to decimal
    $ByteArray=@()
    $ReversedBytes -split '([a-f0-9]{2})' | ForEach-Object {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}
    # seperated by "."'s.
    $IPstring=""
    $ByteArray | ForEach-Object { $IPstring += "$([convert]::ToByte($_,16))." }
    $IP = $IPstring.trimend(".")

    # convert $portEncoded to Hexadecimal
    $portEncodedHex = "{0:X4}" -f $portEncoded
    # reverse the order of the 2 bytes
    $ByteArray=@()
    $portEncodedHex -split '([a-f0-9]{2})' | ForEach-Object {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}

    $ReversedBytes = -join ($ByteArray[$($ByteArray.Length-1)..0])
    # and convert to decimal
    $PORT=[convert]::ToUint64($ReversedBytes,16)

    write-output "$IP : $PORT"
  }
  else {
    write-output "cookie string format is invalid."
    write-output "usage:"
    write-output "  .\Decode-BigIPCookie '375537930.544.0000' "
  }
}

if ($args.count -gt 0) {
  Decode-Cookie $args
}
else {
  write-output " usage:"
  write-output "  Decode-BigIPCookie '375537930.544.0000' "
}