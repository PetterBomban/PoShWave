function Get-ApList
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True)]
        $Session
    )

    Write-Verbose "Getting Ap List.."

    $Uri = $Session.Api + "/ap_list.xml"
    
    $Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get
    [xml]$Response = $Response.Content
    $Response
}
