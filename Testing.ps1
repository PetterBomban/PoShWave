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

# ApList
$con | Get-ApList -Id 533 -Verbose

# Amp Status
#$con | Get-AmpStats -Verbose
