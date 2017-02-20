## Plan:
## AP's and switches show what device they are connected to,
## and what port they are connected to.
## We need to get a list of all switches, and then all ap's.
## After that, we compare the values to see what is connected where.
## Export to excel. Csv?

param
(
    [PScredential]$credential
)

Remove-Module PoShWave
Import-Module .\PoShWave.psm1

$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

$Devices = $con | Get-AirWaveDevice
#$Switches = $Devices | Where-Object { $_.device_category -eq "switch" }
$APs = $Devices | Where-Object { $_.device_category -like "*ap*" }
$Switches = $Devices | Where-Object { $_.device_category -eq "switch" }

## ArrayList to hold already visited AP's
$Visited = New-Object System.Collections.ArrayList

foreach ($AP in $APs)
{
    $ApPort = $AP.upstream_port_index
    $ApConnectedTo = $AP.upstream_device_id
    $ApName = $AP.name
    $ApIp = $AP.lan_ip
    $Switch = $Switches | Where-Object { $_.id -eq $ApConnectedTo }

    ## We've already visited this AP.
    if ($Visited.Contains($ApIp)) { continue }

    ## Quick and dirty to avoid errors
    if ($Switch.name -eq $null) { $Switch = [PSCustomObject]@{ name = @("NOT_CONNECTED")}}
    
    [void]$Visited.Add($ApIp)

    $obj = [PSCustomObject]@{
        Switch = ($Switch.name)[0] ## somehow always returns two of the same switch..
        SwitchApPort = $ApPort
        ApName = $ApName
        ApIp = $ApIp
    }
    $obj
}
