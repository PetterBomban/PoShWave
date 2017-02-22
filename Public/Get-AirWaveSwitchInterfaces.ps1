function Get-AirWaveSwitchInterfaces
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
        $Id
    )
    ## Path to the .csv-file of the gived switch's interfaces
    $Uri = "{0}/nf/csv_export.csv?csv_export_uri=%2Finterface_list&csv_export_list_namespace=aruba_physical_interfaces&csv_export_list_args=ap_id%3D{1}" -f $Session.Api, $Id
    Write-Verbose "Sending request to: $Uri"

    $Date = Get-Date -Format dd-MM-yyy
    $Outfile = Join-Path -Path $ENV:TEMP -ChildPath "$Id _ $Date.csv"
    Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -OutFile $Outfile

    $Csv = Import-Csv -Path $Outfile -Delimiter ","

    ## Ordering the switchports
    Write-Verbose "Ordering ports"
    $OrderedCollection = @()
    $PortNumber = $Csv.Count
    for ($i = 0; $i -le $PortNumber; $i++)
    {
        foreach ($Switchport in $Csv)
        {
            $CurrPort = $Switchport.Interface
            $CurrPort = $CurrPort.Split("/")[1] + "/" + $CurrPort.Split("/")[2]

            ## If the switch only contains "/", it's the mgmt-port
            if ($CurrPort -eq "/") { $CurrPort = "mgmt" }
            
            if ($CurrPort -eq "0/$i" -or $CurrPort -eq "1/$i")
            {
                $OrderedCollection += $Switchport
            }
        }
    }
    $OrderedCollection
}
