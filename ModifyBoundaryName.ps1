
param([parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='CSV File')][string]$CSVFile)

#Conectar a SCCM Management Shell
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#SiteCode
$PSDrive = Get-PSDrive -PSProvider CMSite
Set-Location "$($PSDrive):"

#Variables generales
$Boundaries = Import-CSV $CSVfile

#Porcentaje
$BoundariesCount = $Boundaries.count
$i = 0

#Ciclo
foreach ($line in $Boundaries)
    { 
    
    $i = $i + 1
	$pct = $i/$BoundariesCount * 100
	Write-Progress -Activity "Procesando Boundaries" -Status "Boundary $i de $BoundariesCount - $mb" -PercentComplete $pct

    $Boundary = $line.name
    $Newname = $line.newname
    $Date = Get-Date

    Get-CMBoundary -BoundaryName $Boundary | Set-CMBoundary -NewName $Newname
    if (!$?)
            {
                Write-Host $Date",La modificacion de $Boundary fallo a causa de $($Error[0])" -ForegroundColor Red
            }
            else
            {
                Write-Host $Date",La modificacion de $Boundary se completó satisfactoriamente"  -ForegroundColor Green
            }
    }
