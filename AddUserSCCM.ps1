	#Variables
	
	Import-Module activedirectory
	$Password = ConvertTo-SecureString "Pass" –asplaintext –force
	$DatabaseServer = 'FQDN-SQL'
    $SPN_DB = 'SingleNameSQL'
    $SCCMServer = 'FQDN-SCCM'
    $WSUSServer = 'FQDN-WSUS'
    
	#Usuarios
	
    New-ADUser -SamAccountName SCCM_AdminBra -name SCCM_AdminBra 
	Set-ADAccountPassword -identity SCCM_AdminBra -NewPassword $Password
	Set-ADUser -identity SCCM_AdminBra -Enabled 1 -PasswordNeverExpires 1

	New-ADUser -SamAccountName SCCM_ClientPushBR -name SCCM_ClientPushBR 
	Set-ADAccountPassword -identity SCCM_ClientPushBR -NewPassword $Password
	Set-ADUser -identity SCCM_ClientPushBR -Enabled 1 -PasswordNeverExpires 1

	New-ADUser -SamAccountName SCCM_SQLAdminBR -name SCCM_SQLAdminBR 
	Set-ADAccountPassword -identity SCCM_SQLAdminBR -NewPassword $Password
	Set-ADUser -identity SCCM_SQLAdminBR -Enabled 1 -PasswordNeverExpires 1

	New-ADUser -SamAccountName SCCM_SQLServiceBR -name SCCM_SQLServiceBR 
	Set-ADAccountPassword -identity SCCM_SQLServiceBR -NewPassword $Password
	Set-ADUser -identity SCCM_SQLServiceBR -Enabled 1 -PasswordNeverExpires 1
			
	New-ADUser -SamAccountName SCCM_SQLReportingBR -name SCCM_SQLReportingBR 
	Set-ADAccountPassword -identity SCCM_SQLReportingBR -NewPassword $Password
	Set-ADUser -identity SCCM_SQLReportingBR -Enabled 1 -PasswordNeverExpires 1
	
	#Grupos
	
	New-ADGroup -name SCCM_AdminsBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_AdminsBR
	New-ADGroup -name SCCM_OperatorsBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_OperatorsBR
	New-ADGroup -name SCCM_ReadOnlyBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_ReadOnlyBR
	New-ADGroup -name SCCM_ReportingBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_ReportingBR
    New-ADGroup -name SCCM_SitesServersBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_SitesServersBR
	New-ADGroup -name SCCM_SupportBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_SupportBR
    New-ADGroup -name SCCM_WebServersBR -GroupCategory Security -GroupScope Global -SamAccountName SCCM_WebServersBR
    
    #Agregar usuarios a Grupos

	Add-ADGroupMember -identity SCCM_AdminsBR -Members SCCM_AdminBra
    Add-ADGroupMember -identity 'Domain Admins' -Members SCCM_AdminBra
    Add-ADGroupMember -identity SCCM_SitesServersBR -Members $SCCMServer, $DatabaseServer, $WSUSServer
    Add-ADGroupMember -identity SCCM_WebServersBR -Members $SCCMServer, $DatabaseServer, $WSUSServer
    
	#SPN
	
	setspn -A MSSQLSvc/$SPN_DB:1433 LOJASCOPPEL\SCCM_SQLServiceBR
	setspn -A MSSQLSvc/$DatabaseServer:1433 LOJASCOPPEL\SCCM_SQLServiceBR
	
	#Verificar SPN
    setspn SCCM_SQLServiceBR