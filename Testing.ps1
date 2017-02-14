Remove-Module PoShWave
Import-Module .\PoShWave.psm1

$cred = Get-Credential
$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $cred

$con | Invoke-AirWaveQuery -Query "Ap List" -Verbose
