Import-Module .\PoShWave.psm1

#$cred = Get-Credential
$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no/LOGIN" -Credential $cred
$con
