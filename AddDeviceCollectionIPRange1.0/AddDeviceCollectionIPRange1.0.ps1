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

#Conectar a SCCM Management Shell
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#SiteCode
$PSDrive = Get-PSDrive -PSProvider CMSite
Set-Location "$($PSDrive):"

#Intervalo de actualizacion
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 7

#Limite de colecccion
$LimitingCollection = "All Systems"

#Variables generales
$IPRanges = Import-CSV $CSVfile
$DateReport = Get-Date -Format 'dd-MMM-yyy_hh.mm'

#Porcentaje
$IPRangesCount = $IPRanges.count
$i = 0

#Ciclo
foreach ($line in $IPRanges)
    { 
    
    $i = $i + 1
	$pct = $i/$IPRangesCount * 100
	Write-Progress -Activity "Processing Collection" -Status "Processing Collection $i of $IPRangesCount - $mb" -PercentComplete $pct

    $CollectionName = $line.CollectionName
    $Octetos = $line.octets
    $IPRangeType = $line.start
    $Date = Get-Date

    #Query
    $QueryIPRange_01to63 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where (SMS_R_System.IPAddresses like '$Octetos.[1-6][0-9]' or SMS_R_System.IPAddresses like '$Octetos.[0-9]') and SMS_R_System.IPAddresses not like '$Octetos.6[4-9]'"
    $QueryIPRange_64to127 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where (SMS_R_System.IPAddresses like '$Octetos.6[4-9]' or SMS_R_System.IPAddresses like '$Octetos.[7-9][0-9]' or SMS_R_System.IPAddresses like '$Octetos.1[0-2][0-9]') and SMS_R_System.IPAddresses not like '$Octetos.12[8-9]'"
    $QueryIPRange_128to191 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where (SMS_R_System.IPAddresses like '$Octetos.12[8-9]' or SMS_R_System.IPAddresses like '$Octetos.1[3-9][0-9]') and SMS_R_System.IPAddresses not like '$Octetos.19[2-9]'"
    $QueryIPRange_192to254 = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IPAddresses like '$Octetos.19[2-9]' or SMS_R_System.IPAddresses like '$Octetos.2[0-5][0-9]'"
    
    Write-Host "-------------------------------------------------------"

    if ($IPRangeType -eq 0)
        {
        
        Write-Host "Creando la colección de dispositivos $CollectionName ..." -ForegroundColor White
        New-CMDeviceCollection -Name $CollectionName -Comment $CollectionName -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $QueryIPRange_01to63 -RuleName $CollectionName
            if (!$?)
            {
                Write-Host $Date",La creación de $CollectionName fallo a causa de $($Error[0])" -ForegroundColor Red
                #Write-Output $Date",La creación de la colección $CollectionName fallo a causa de $($Error[0])" | Out-File -FilePath $LogFile -Append
            }
            else
            {
                Write-Host $Date",La creación de $CollectionName se completó satisfactoriamente"  -ForegroundColor Green
                #Write-Output $Date",La creación de la colección $CollectionName se completó satisfactoriamente" | Out-File -FilePath $LogFile -Append
            }
        }
        else
        {
           if ($IPRangeType -eq 64)
           {
            Write-Host "Creando la colección de dispositivos $CollectionName ..." -ForegroundColor White
            New-CMDeviceCollection -Name $CollectionName -Comment $CollectionName -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $QueryIPRange_64to127 -RuleName $CollectionName
                if (!$?)
                {
                    Write-Host $Date",La creación de $CollectionName fallo a causa de $($Error[0])" -ForegroundColor Red
                    #Write-Output $Date",La creación de $CollectionName fallo a causa de $($Error[0])" | Out-File -FilePath $LogFile -Append
                }
                else
                {
                    Write-Host $Date",La creación de $CollectionName se completó satisfactoriamente" -ForegroundColor Green
                    #Write-Output $Date",La creación de $CollectionName se completó satisfactoriamente" | Out-File -FilePath $LogFile -Append
                }
           }
           else
           {
               if ($IPRangeType -eq 128)
               {

                Write-Host "Creando la colección de dispositivos $CollectionName ..." -ForegroundColor White
                New-CMDeviceCollection -Name $CollectionName -Comment $CollectionName -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
                Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $QueryIPRange_128to191 -RuleName $CollectionName
                    if (!$?)
                    {
                        Write-Host $Date",La creación de $CollectionName fallo a causa de $($Error[0])" -ForegroundColor Red
                        #Write-Output $Date",La creación de $CollectionName fallo a causa de $($Error[0])" | Out-File -FilePath $LogFile -Append
                    }
                    else
                    {
                        Write-Host $Date",La creación de $CollectionName se completó satisfactoriamente" -ForegroundColor Green
                        #Write-Output $Date",La creación de $CollectionName se completó satisfactoriamente" | Out-File -FilePath $LogFile -Append
                    }
               }
               else
               {
                   if ($IPRangeType -eq 192)
                   {

                    Write-Host "Creando la colección de dispositivos $CollectionName ..." -ForegroundColor White
                    New-CMDeviceCollection -Name $CollectionName -Comment $CollectionName -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
                    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $QueryIPRange_192to254 -RuleName $CollectionName
                        if (!$?)
                        {
                            Write-Host $Date",La creación de $CollectionName fallo a causa de $($Error[0])" -ForegroundColor Red
                            #Write-Output $Date",La creación de $CollectionName fallo a causa de $($Error[0])" | Out-File -FilePath $LogFile -Append
                        }
                        else
                        {
                            Write-Host $Date",La creación de $CollectionName se completó satisfactoriamente" -ForegroundColor Green
                            #Write-Output $Date",La creación de $CollectionName se completó satisfactoriamente" | Out-File -FilePath $LogFile -Append
                        }
                   }
                   else
                   {
                    Write-Host $Date",Rango de IP no encontrado para colección $CollectionName" -ForegroundColor Red
                   }
                }
            }            
        }
    }
