<#
.SYNOPSIS
AddDistributionpointSSL-v1.0.ps1 - Script para crear multiples distribution point tipo HTTPS en SCCM.

.DESCRIPTION 
Script para crear multiples distribution point tipo HTTPS en SCCM a partir de lo datos de un archivo CSV,
adicionalmente agrega el ditribution point creado al distribution group que le corresponde y por ultimo 
se agrega a un grupo que contiene a todos los distribution points en el sitio.

.NOTES
Written By: Roberto Carlos Oviedo Amaro
Website:	http://www.axen.pro
Twitter:	@roberto_oviedo
Blog:       -
Git:        https://github.com/rcoviedo

.PARAMETER CSVFile
CSV Filename

.EXAMPLES
    .\AddDistributionpointSSL-v1.0.ps1 -CSVfile C:\Software\DP01-01-2016.csv
 #>

param([parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='CSV File')][string]$CSVFile)

#Conectar a SCCM Management Shell
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#SiteCode
$PSDrive = Get-PSDrive -PSProvider CMSite
Set-Location "$($PSDrive):"

#Variables generales
$DPServers = Import-CSV $CSVfile
$CA = 'coppel-PDCCOPPEL-CA' #Cambiar para incluir el nombre de la CA que firmara los certificados.
$SCCMTemplate = 'SCCMDistributionPointCert' #Cambiar para incluir el nombre del template de certificado para Distribution point.
$SiteCode = 'MEX' #Cambiar este valor por el codigo de sitio correspondiente
$AllDPoints = 'MEX - All Distributions Points' #Cambiar para incluir el grupo que contiene a todos los DPs en el site, es necesario crearlo antes de ejecutar el script.

#Porcentaje
$DPServersCount = $DPServers.count
$i = 0

#Ciclo
foreach ($line in $DPServers)
    { 
    
    $i = $i + 1
	$pct = $i/$DPServersCount * 100
	Write-Progress -Activity "Procesando Distribution point" -Status "Distribution point $i de $DPServersCount - $mb" -PercentComplete $pct

    $DPServer = $line.name
    $DPGroup = $line.group
    $FilePath = 'E:\SCCM_DPoints_Cert\'+$DPServer+'.pfx' #Cambiar para ubicar en otro folder los certificados PFX
    $Date = Get-Date

    Write-Host "-----------------------------------------------"
    Write-Host "////// $DPServer - Testing connection... \\\\\\"
    #Probar si el equipo esta en linea
    if(Test-Connection -ComputerName $DPServer -Count 1 -Quiet)
    {
        #Revisar si ya existe un distribution point con ese nombre
        if (Get-CMDistributionPoint -SiteSystemServerName $DPServer)
        {
            Write-Host "$DPServer ya existe como Distribution point" -ForegroundColor Yellow
        }
        else
        {
            #Crear certificado
            Set-Location 'Cert:\LocalMachine\My'
            $cert = Get-Certificate -Template $SCCMTemplate -Url ldap:///$CA -SubjectName "CN=$DPServer" -DnsName $DPServer -CertStoreLocation Cert:\LocalMachine\My
            $thumbprint = $cert.Certificate.Thumbprint

            #Exportar certificado en formato PFX
            $secure_string_pwd = ConvertTo-SecureString -String "Valyrio1232811" -Force –AsPlainText
            Get-ChildItem cert:\localmachine\my | where {$_.thumbprint -eq "$thumbprint"} | Export-PfxCertificate -FilePath $FilePath -Password $secure_string_pwd

            #Remover certificado
            Set-Location -Path cert:\
            Get-ChildItem cert:\localmachine\my | where {$_.thumbprint -eq "$thumbprint"} | Remove-Item -DeleteKey

            #Crear Distribution point
            New-CMSiteSystemServer -ServerName $DPServer -SiteCode $SiteCode
            Add-CMDistributionPoint -SiteSystemServerName $DPServer -SiteCode $SiteCode -CertificatePath $FilePath -CertificatePassword $secure_string_pwd -InstallInternetServer -EnableBranchCache -ClientConnectionType 'Intranet' -MinimumFreeSpaceMB '5120' -PrimaryContentLibraryLocation 'M' -PrimaryPackageShareLocation 'M' -EnableValidateContent
            Write-Host "Instalando Distribution point en servidor $DPServer ..." -ForegroundColor Green
            Start-Sleep -Seconds 300 #Esperar 5 minutos para que termine el proceso de instalación para agregar DP a un DPGroup.
            
            #Crear Distribution point group
            if (Get-CMDistributionPointGroup -SiteSystemServerName $DPGroup)
            {
                Write-Host "Agregando Distribution point a los grupos $DPGroup & $AllDPoints ..." -ForegroundColor Green
                Add-CMDistributionPointToGroup -DistributionPointName $DPServer -DistributionPointGroupName $AllDPoints
                Add-CMDistributionPointToGroup -DistributionPointName $DPServer -DistributionPointGroupName $DPGroup
            }
            else
            {
                Write-Host "Creando Distribution point group $DPGroup ..." -ForegroundColor Green
                New-CMDistributionPointGroup –Name $DPGroup
                Start-Sleep -Seconds 30 #Esperar 30 segundos para que termine el proceso de creación del Distribution point group.
                Write-Host "Agregando Distribution point a los grupos $DPGroup & $AllDPoints ..." -ForegroundColor Green
                Add-CMDistributionPointToGroup -DistributionPointName $DPServer -DistributionPointGroupName $AllDPoints
                Add-CMDistributionPointToGroup -DistributionPointName $DPServer -DistributionPointGroupName $DPGroup
            }
        }
    }
    else 
        {
            Write-Host "$DPServer no responde" -ForegroundColor Red
        } 
    }
