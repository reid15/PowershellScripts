
param 
(
  [string] $ServerName,
  [int] $StartingPort,
  [int] $EndingPort
)

$CurrentPortNumber = $StartingPort

$ping = new-object System.Net.NetworkInformation.Ping
$result = $ping.send($ServerName)
if (! $?){

write-host "Server Name: $ServerName - Not Connected" -foregroundcolor Red

} else {

write-host "Server Name: $ServerName - Connected" -foregroundcolor Green

for (; $CurrentPortNumber -le $EndingPort; $CurrentPortNumber++)
{

$tcp = $null
try {
$tcp = New-Object System.Net.Sockets.TcpClient($ServerName, $CurrentPortNumber)                
} catch {
}

if ($tcp –eq $null) {
	write-host "Port: $CurrentPortNumber - Not Connected" -foregroundcolor Red
} else {
	write-host "Port: $CurrentPortNumber - Connected" -foregroundcolor Green 
	$tcp.client.disconnect($False)
}

$tcp = $null

}

}









