## Requires ImportExcel-module
## Install-Module ImportExcel
param
(
    [PScredential]$credential
)

Remove-Module PoShWave -ErrorAction SilentlyContinue
Import-Module "C:\Users\admin\Documents\GitHub\PoShWave\PoShWave.psm1", ImportExcel

$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

function Export-SwitchesAndAPsToExcel
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

            Set-CellStyle $workSheet 1 $lastColumn Solid SkyBlue

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
            CellStyleSB = $CellStyles
            BoldTopRow = $True
            Autosize = $True
        }
        $Select = @(
            "SwitchName",
            "SwitchIp",
            "SwitchMac",
            "SwitchSerial",
            "SwitchPort",
            "ApName",
            "ApIp",
            "ApMac",
            "ApSerial"
        )
        $Export = $Switch.Value
        $Export | Select-Object $Select | Sort-Object SwitchPort | Export-Excel @ExportSplat
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
        [int]$ApPort = $AP.upstream_port_index
        $ApConnectedTo = $AP.upstream_device_id
        $ApName = $AP.name
        $ApIp = $AP.lan_ip
        $ApMac = $AP.lan_mac
        $ApSerial = $AP.serial_number

        $Switch = $Switches | Where-Object { $_.id -eq $ApConnectedTo }
        ## Quick and dirty to avoid errors
        if ($Switch.name -eq $null) { $Switch = [PSCustomObject]@{ name = "_UNKNOWN"}}
        $SwitchName = $Switch.name
        $SwitchIp = $Switch.lan_ip
        $SwitchMac = $Switch.lan_mac
        $SwitchSerial = $Switch.serial_number

        ## Skip already visited APs (since the api returns one several times..?)
        if ($Visited.Contains($ApIp)) { continue }
        [void]$Visited.Add($ApIp)

        $obj = [PSCustomObject]@{
            SwitchName = $SwitchName
            SwitchIp = $SwitchIp
            SwitchMac = $SwitchMac
            SwitchSerial = $SwitchSerial
            SwitchPort = $ApPort
            ApName = $ApName
            ApIp = $ApIp
            ApMac = $ApMac
            ApSerial = $ApSerial
        }
        $Collection[$SwitchName] += @($obj)
    }
    
    ## Copy of collection to stop "Collection was modified.."-troubles
    $CollectionCopy = $Collection.PSObject.Copy()

    ## Ugly logic for determining the number of ports on the switch
    ## Works by getting the $Switch.model.'#text' field and parsing
    ## out the number of ports.
    foreach ($Switch in $Collection.GetEnumerator())
    {
        ## We do this because some times we couldn't get the name of the switch
        ## an AP is connected to, so we just create placeholder values.
        if (!($SwitchInfo = $Switches | Where-Object name -eq $Switch.name))
        {
            $SwitchName = "_UNKNOWN"
            $SwitchPortNum = 48
        }
        else
        {
            $SwitchName = $Switch.name
            $SwitchPortNum = $SwitchInfo.model.'#text'
            $SwitchPortNum = ($SwitchPortNum.Split("-"))[1] -replace "P"
        }
        $SwitchMac = $SwitchInfo.lan_mac
        $SwitchSerial = $SwitchInfo.serial_number
        $SwitchIp = $SwitchInfo.lan_ip

        ## An array of ports already containing an AP/AirWave-detected device.
        $SwitchApConnectedPorts = @()
        $Switch.Value.SwitchPort | ForEach-Object {
            $SwitchApConnectedPorts += $PSItem
        }

        ## Here we go through the $Collection to determine which ports
        ## are not connected to an AP. If they are not, we just create 
        ## an empty element with the free port number for prettier
        ## Excel documentation.
        1..$SwitchPortNum | ForEach-Object {
            $i = $PSItem            
            if (!($SwitchApConnectedPorts -contains $i))
            {
                Write-Verbose "Port $i - does not contain an AP, creating empty."
                $EmptyPortObj = [PSCustomObject]@{
                    SwitchName = $SwitchName
                    SwitchIp = $SwitchIp
                    SwitchMac = $SwitchMac
                    SwitchSerial = $SwitchSerial
                    SwitchPort = $i
                }
                $CollectionCopy[$Switch.name] += @($EmptyPortObj)
            }
        }
    }
    $CollectionCopy
}

$TestPath = "C:\users\admin\documents\github\poshwave\test.xlsx"
$con | Get-SwitchesAndAPs | Export-SwitchesAndAPsToExcel -Path $TestPath
