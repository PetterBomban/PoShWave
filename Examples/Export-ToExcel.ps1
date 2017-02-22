## Requires ImportExcel-module
## Install-Module ImportExcel

param
(
    [PScredential]$credential
)

Remove-Module PoShWave -ErrorAction SilentlyContinue
Import-Module ..\PoShWave.psm1, ImportExcel

$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

function Export-SwitchesAndAPsToCsv
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        [Hashtable] $Collection,

        [Parameter( Mandatory = $True,
                    Position = 1)]
        [String] $Path = "C:\"
    )

    $col = @()
    foreach ($Switch in $Collection.GetEnumerator())
    {
        ## Setting custom styles to the table
        $CellStyles = {
            param
            (
                $workSheet,
                $totalRows,
                $lastColumn
            )
            
            Set-CellStyle $workSheet 1 $lastColumn Solid Gray

            foreach ($row in (2..$totalRows | Where-Object {  $_ % 2 -eq 0 }))
            {
                Set-CellStyle $workSheet $row $lastColumn Solid LightGray
            }
            foreach ($row in (2..$totalRows | Where-Object {  $_ % 2 -eq 1 }))
            {
                Set-CellStyle $workSheet $row $lastColumn Solid White
            }
        }
        $ExportSplat = @{
            Path = $Path
            WorkSheetname = $Switch.Key
            Autosize = $True
            CellStyleSB = $CellStyles
        }
        $Switch.Value | Sort-Object Port | Export-Excel @ExportSplat
    }
}

## Exports switches and ap's in a format like:
#Name                  Value
#----                  -----
#003-H151.KS22-SW01    {@{ApName=003-TO116-AP01; ApIp=10.3.36.61; SwitchApPort=15}, [..]
function Get-SwitchesAndAPs
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [PSCustomObject] $Session
    )

    $Devices = $Session | Get-AirWaveDevice
    $APs = $Devices | Where-Object { $_.device_category -like "*ap*" }
    $Switches = $Devices | Where-Object { $_.device_category -eq "switch" }

    ## ArrayList to hold already visited AP's
    $Visited = New-Object System.Collections.ArrayList

    ## Gathering all of them by the switch name
    $Collection = @{}

    foreach ($AP in $APs)
    {
        $ApPort = $AP.upstream_port_index
        $ApConnectedTo = $AP.upstream_device_id
        $ApName = $AP.name
        $ApIp = $AP.lan_ip

        $Switch = $Switches | Where-Object { $_.id -eq $ApConnectedTo }
        ## Quick and dirty to avoid errors
        if ($Switch.name -eq $null) { $Switch = [PSCustomObject]@{ name = @("_UNKNOWN")}}
        $SwitchName = ($Switch.name)[0]

        ## Skip already visited APs (since the api returns one several times..?)
        if ($Visited.Contains($ApIp)) { continue }
        [void]$Visited.Add($ApIp)

        $obj = [PSCustomObject]@{
            SwitchName = $SwitchName
            Port = $ApPort
            ApName = $ApName
            ApIp = $ApIp
        }
        $Collection[$SwitchName] += @($obj)
    }
    $Collection
}


