function Get-AirWaveDeviceDetails
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [PSCustomObject] $Session,

        [Parameter( Mandatory = $True,
                    Position = 1 )]
        [Int] $Id
    )

    Write-Verbose "Gathering device details for device $Id"
    $Uri = $Session.Api + "/ap_detail.xml?id=$Id"
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get

    $Response
}