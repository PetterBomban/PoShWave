## Ex.:
## $Params = "id=79", "id=364", "ap_folder_id=3" # ..
## $Session | Invoke-AirWaveQuery -Query ap_list -Parameters $Params
function Invoke-AirWaveRawQuery
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
        [String] $Query,

        [Parameter( Mandatory = $True,
                    Position = 2 )]
        [String[]] $Parameters
    )
    
    $Uri = $Session.Api + "/$Query.xml?"
    foreach ($Param in $Parameters)
    {
        $Uri += "$Param&"
    }
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get
    [xml]$Response
}
