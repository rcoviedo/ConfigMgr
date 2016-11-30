<#
.SYNOPSIS
AddDeviceCollectionIPRange1.0.ps1 - Script para crear multiples device collection basados en ranngos de IP en SCCM.

.DESCRIPTION
Script para crear multiples device collection basados en rangos de IP en SCCM a partir de un archivo CSV,
los rangos son marcara /26, solo se ocupan los primeros tres octetos de la IP.

.NOTES
Written By: Roberto Carlos Oviedo Amaro
Website:    http://www.axen.pro
Twitter:    @roberto_oviedo
Blog:       -
Git:        https://github.com/rcoviedo

.PARAMETER CSVFile
CSV File name

.EXAMPLE
.\AddDeviceCollectionIPRange1.0.ps1 -CSVFile C:\Software\Collection-01-01-2016.csv
#>

param([parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='CSV File')][string]$CSVFile)



