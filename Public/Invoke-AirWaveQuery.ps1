## Probably not going to do it this way, ignore this file for now
function Invoke-AirWaveQuery
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True
        )]
        $Session,

        [Parameter( Mandatory = $True,
                    Position = 1
        )]
        [ValidateSet("AP List")]
        $Query
    )

    ## Connecting the $Query to a function
    $Actions = @{
        "AP List" = $Session | Get-ApList
        "more_to_come" = "yep"
    }

    ## Perform the query
    $Actions[$Query]
}
