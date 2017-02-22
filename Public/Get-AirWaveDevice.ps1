function Get-AirWaveDevice
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [PSCustomObject] $Session,

        [Parameter( Mandatory = $False,
                    Position = 1 )]
        [Int] $Id,

        [Parameter( Mandatory = $False )]
        [ValidateSet("ap", "controller", "switch")]
        [String] $DeviceType
    )

    ## Construct links like so:
    ## $Api/ap_list.xml?id=123&anotherKey=2& etc..
    Write-Verbose "Getting Ap List.."
    $Uri = $Session.Api + "/ap_list.xml?"
    foreach ($Param in $PSBoundParameters.GetEnumerator())
    {
        $Key = ($Param.Key).toLower()
        $Value = $Param.Value
        if (!($Key -eq "id")) { continue } ## TODO: Better way to do this?
        $Uri += ($Key + "=" + $Value + "&")
    }
    Write-Verbose "Constructed URI: $Uri"
    [xml]$Response = Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -Method Get

    ## if $DeviceType is set, we only return the elements that are of that type
    ## otherwise we just return the whole response
    if (!($DeviceType))
    {
        $Response.amp_ap_list.ap
    }
    else
    {
        $Response.amp_ap_list.ap | ForEach-Object {
            $PSItem | Where-Object { $_.device_category -like "*$DeviceType*" }
        }
    }
}
