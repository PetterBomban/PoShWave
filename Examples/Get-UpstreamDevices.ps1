param
(
    [PScredential]$credential
)

Remove-Module PoShWave
Import-Module ..\PoShWave.psm1

$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential
$Devices = $con | Get-AirWaveDevice
$APs = $Devices | Where-Object { $_.device_category -like "*ap*" }
$Switches = $Devices | Where-Object { $_.device_category -eq "switch" }

$Switches
