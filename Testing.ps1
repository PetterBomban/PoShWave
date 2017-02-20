param
(
    [PScredential]$credential
)

Remove-Module PoShWave
Import-Module .\PoShWave.psm1

if(!($credential))
{
    $credential = Get-Credential
}
$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

# Full list of devices
#$con | Get-AirWaveDevice -Verbose

# Sort by device type
# $con | Get-AirWaveDevice -DeviceType "switch" -Verbose

## Export switches to csv (TODO: Excel?)
$switches = $con | Get-AirWaveDevice -DeviceType "switch"
$switches


# Amp Status
#$con | Get-AmpStats -Verbose
