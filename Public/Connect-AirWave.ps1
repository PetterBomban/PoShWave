## Returns a session-cookie used for authenticating queries to API
function Connect-AirWave
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $True,
                    Position = 0 )]
        [string]$Api,
        [Parameter( Mandatory = $True,
                    Position = 1 )]
        [pscredential]$Credential
    )

    ## We need to add /LOGIN to the Api link
    $ApiLogin = "$Api/LOGIN"

    ## Fixes: "Invoke-WebRequest : The request was aborted: Could not create SSL/TLS secure channel"
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")

    ## credential_0=username, credential_1=password
    $Body = @{
        credential_0 = $Credential.UserName
        credential_1 = $Credential.GetNetworkCredential().Password
        destination = '/'
        login = 'Log In'
    }

    ## Send post request to login page to get our SessionID cookie
    $Cookie = Invoke-WebRequest -Uri $ApiLogin -Method Post -Body $Body -SessionVariable Session
    if (!($Cookie.Headers.'X-BISCOTTI'))
    {
        throw "Failed to authenticate with AMP."
    }

    [PSCustomObject]@{
        "Cookie" = $Cookie.Headers.'X-BISCOTTI'
        "Api" = $Api
        "Credential" = $Credential
        "Session" = $Session
    }
}
