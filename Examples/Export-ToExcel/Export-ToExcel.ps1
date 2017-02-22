param
(
    [PScredential]$credential
)

Remove-Module PoShWave -ErrorAction SilentlyContinue
Import-Module "C:\Users\admin\Documents\GitHub\PoShWave\PoShWave.psm1", ImportExcel

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

function Export-ToExcel
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        $Collection
    )
    process
    {
        $Collection
    }
}

$con | Get-SwitchInterfaces | Export-ToExcel