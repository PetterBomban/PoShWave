# Export-ToExcel

This script will export switches that have accesss points active on them.

(This means that switches that DO NOT have AP's are not detected here, this is a W.I.P).

Do not change any of the fields in Excel that are automatically generated, as these will be overwritten when the script is ran again. You can safely add custom fields and custom data to these fields.

## Working on

* Making the script respect data in generated fields (unless -Force is used)
* Adding switches that do not have any devices connected to them (in AirWave)
