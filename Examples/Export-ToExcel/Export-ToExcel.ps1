param
(
    [PScredential]$credential
)

Remove-Module PoShWave -ErrorAction SilentlyContinue
Import-Module "C:\Users\admin\Documents\GitHub\PoShWave\PoShWave.psm1" #, ImportExcel

$con = Connect-AirWave -Api "https://900-araw-01.akershus-fk.no" -Credential $credential

function Get-SwitchInterfaces
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        [PSCustomObject] $Session
    )

    $Collection = @()
    $Devices = $Session | Get-AirWaveDevice -DeviceType "switch"
    foreach ($Device in $Devices)
    {
        $CurrDeviceId = $Device.id
        $CurrDeviceName = $Device.name
        
        $InterfaceObj = $Session | Get-AirWaveSwitchInterfaces -Id $CurrDeviceId
        $SwitchObj = [PSCustomObject]@{
            SwitchName = $CurrDeviceName
            SwitchId = $CurrDeviceId
            SwitchPorts = @($InterfaceObj)
        }
        $Collection += @($SwitchObj)
    }
    $Collection
}

function Get-APsWithSwitches
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        [PSCustomObject] $Session
    )

    $Devices = $Session | Get-AirWaveDevice 
    $Switches = $Devices | Where-Object 'device_category' -eq "switch"
    $APs = $Devices | Where-Object 'device_category' -like "*ap*"

    ## Gather access points that we have already looped through
    ## (AirWave some times returns several of the same Ap..)
    $VisitedAps = New-Object System.Collections.ArrayList

    ## Gather all AP's, grouped by which switch they are connected to
    $Collection = @{}

    foreach ($Ap in $APs)
    {
        ## Skip already visited (looped through) AccessPoints
        if ($VisitedAps.Contains($Ap.lan_ip)) { continue }
        [Void]$VisitedAps.Add($Ap.lan_ip)

        ## AP variables
        [int]$ApSwitchPort = $Ap.upstream_port_index
        $ApConnectedTo = $Ap.upstream_device_id
        $ApName = $Ap.name
        $ApIp = $Ap.lan_ip
        $ApMac = $Ap.lan_mac
        $ApSerial = $Ap.serial_number

        ## Switch variables
        $SwitchConnected = $Switches | Where-Object id -eq $ApConnectedTo
        ## Quick and dirty to avoid errors
        if ($SwitchConnected.name -eq $null)
        {
            $SwitchConnected = [PSCustomObject]@{ name = "_UNKNOWN"}
        }
        $SwitchName = $SwitchConnected.name
        $SwitchIp = $SwitchConnected.lan_ip
        $SwitchMac = $SwitchConnected.lan_mac
        $SwitchSerial = $SwitchConnected.serial_number
        $SwitchId = $SwitchConnected.id

        $Obj = [PSCustomObject]@{
            SwitchId = $SwitchId
            SwitchName = $SwitchName
            SwitchIp = $SwitchIp
            SwitchMac = $SwitchMac
            SwitchSerial = $SwitchSerial
            ApConnectedTo = $ApConnectedTo
            ApName = $ApName
            ApIp = $ApIp
            ApMac = $ApMac
            ApSerial = $ApSerial
        }
        $Collection.SwitchName
        $Collection[$SwitchName] += @($Obj)
    }
    $Collection
}

# $con | Get-SwitchInterfaces | Add-APsToSwitches $APs | Export-ToExcel ...
function Add-APsToSwitches
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0)]
        [PSCustomObject] $APsAndSwitches,

        [Parameter( Mandatory = $True,
                    Position = 1)]
        [PSCustomObject] $SwitchPorts
    )

    ## Collecting switches with AP's in an easier format to work with
    ## TODO: Fix this "upstream"!
    $SwitchWithAPs = @()
    $APsAndSwitches.Keys | ForEach-Object {
        $SwitchName = $PSItem
        $AccessPoints = $APsAndSwitches.$SwitchName

        $Obj = [PSCustomObject]@{
            SwitchName = $SwitchName
            AccessPoints = $AccessPoints
        }
        $SwitchWithAPs += @($Obj)
    }

    ## Now we go through each switch with its switch ports.
    ## Here we need to:
    ## 1) Link a switch with switchports ($SwitchPort) with a switch with APs
    ## 2) Find the interface where the AP is connected on both objects
    ## 3) Append the AP-information to the correct switch port
    ## 4) Output
    foreach ($SwitchPort in $SwitchPorts.GetEnumerator())
    {
        if ($SwitchWithAPs.SwitchName -contains $SwitchPort.SwitchName)
        {
            $CurrSwitchWithAPs =
                $SwitchWithAPs | Where-Object { $_.SwitchName -eq $SwitchPort.SwitchName }
            Write-Debug $CurrSwitchWithAPs
            
            ## These two now match
            $SwitchPort # Current SwitchPort Object, no APs
            $CurrSwitchWithAPs ## Current Switch with AP

            ## Next: Find out 
        }
        #>
    }
}

function Export-ToExcel
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        [PSCustomObject] $Collection,

        [Parameter( Mandatory = $True,
                    Position = 1)]
        [String] $Path,

        [Parameter( Mandatory = $False,
                    Position = 2)]
        [String] $DataMember,

        [Parameter( Mandatory = $False,
                    Position = 3)]
        [Array] $Select = @()
    )
    process
    {
        ## Defining styles in the excel sheets
        $CellStyleSB = {
            param
            (
                $workSheet,
                $totalRows,
                $lastColumn
            )

            Set-CellStyle $workSheet 1 $lastColumn Solid SkyBlue

            foreach ($row in (2..$totalRows | Where-Object { $_ % 2 -eq 0 }))
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
            WorkSheetName = $Collection.SwitchName
            CellStyleSB = $CellStyleSB
            BoldTopRow = $True
            Autosize = $True
            FreezeTopRow = $True
        }
        ## Testing for $DataMember
        if(!($Export = $Collection.$DataMember))
        {
            $Export = $Collection
        }
        $Export | Select-Object $Select #| Export-Excel @ExportSplat
    }
}

$Doc = "C:\Users\admin\Documents\GitHub\PoShWave\SwitchPorts.xlsx"
$APs = $con | Get-APsWithSwitches
$SwitchPorts = $con | Get-SwitchInterfaces

$SelectSplat = @(

)
Add-APsToSwitches -APsAndSwitches $APs -SwitchPorts $SwitchPorts 
#|Export-ToExcel -Path $Doc -Select $SelectSplat

#$con | Get-SwitchInterfaces | Export-ToExcel -Path $SwitchPortsPath -DataMember "SwitchPorts"
