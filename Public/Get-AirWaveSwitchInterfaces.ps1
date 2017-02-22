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
    ## Store the output csv in TEMP
    $Date = Get-Date -Format dd-MM-yyy
    $Outfile = Join-Path -Path $ENV:TEMP -ChildPath "$Id_$Date"
    Invoke-WebRequest -Uri $Uri -WebSession $Session.Session -OutFile $Outfile

    $CsvFile = Get-Content -Path $Outfile
    $Csv = $CsvFile | ConvertFrom-Csv -Delimiter ","
    $Csv
}
