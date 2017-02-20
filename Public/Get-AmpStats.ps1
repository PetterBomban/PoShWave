function Get-AmpStats
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [PSCustomObject]$Session
    )

    Write-Verbose "Getting AMP stats.."
    $Uri = $Session.Api + "/amp_stats.xml"

    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get
    [xml]$Response.Content
}
