function Get-AirWaveClientDetail
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
        [String] $MacAddress
    )

    $Uri = "{0}/client_detail.xml?mac={1}" -f $Session.Api, $MacAddress
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get
    [xml]$Response.amp_client_detail.client
}
