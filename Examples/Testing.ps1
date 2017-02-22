param
(
    [PScredential]$credential
)

Remove-Module PoShWave
Import-Module ..\PoShWave.psm1

if(!($credential))
{
    $credential = Get-Credential
}
$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

## Testing client detail
$con | Get-AirWaveClientDetail -Mac "78:F8:82:B6:64:A5"

# Full list of devices
#$con | Get-AirWaveDevice -Verbose

# Sort by device type
# $con | Get-AirWaveDevice -DeviceType "switch" -Verbose

# Get individual device
#$con | Get-AirWaveDevice -Id 3481 -Verbose

# Get device details
# I get either a license error or a permission error...
#$con | Get-AirWaveDeviceDetails -Id 3481 -Verbose

# Amp Status
#$con | Get-AmpStats -Verbose
