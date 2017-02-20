function Get-ApList
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [PSCustomObject]$Session,

        [Parameter( Mandatory = $False,
                    Position = 1 )]
        [Int]$Id
    )

    Write-Verbose "Getting Ap List.."
    $Uri = $Session.Api + "/ap_list.xml?"
    foreach ($Param in $PSBoundParameters.GetEnumerator())
    {
        $Key = ($Param.Key).toLower()
        $Value = $Param.Value
        ## TODO: Better way to do this?
        if ($Key -ne "id") { continue }
        ## Construct links like so:
        ## $Api/ap_list.xml?id=123&anotherKey=2& etc..
        $Uri += ($Key + "=" + $Value + "&")
    }
    Write-Verbose "Constructed URI: $Uri"
    
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get
    [xml]$Response.Content
}
