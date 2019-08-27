#################################################################################################################
#Author:   Richie Schuster - SCCMOG.COM                                                                         #
#ModdedBy: You Name Here                                                                                        #
#Script:   Import-AddToCollectionfromCSV.ps1                                                                    #
#Date:     26/06/2017                                                                                           #
#Usage:    Import-AddToCollectionfromCSV.ps1 -CollectionID S0G001BA -SiteCode S0G -CSVin "C:\Temp\YourCSV.csv"  #
#################################################################################################################

#Params for Script execution
param 
(
[parameter(mandatory=$true,HelpMessage="Please, provide a Collection ID to add the machines to e.g. P01000F4 ")][ValidateNotNullOrEmpty()][String]$CollectionID,
[parameter(mandatory=$true,HelpMessage="Please, provide a SCCM SiteCode. e.g S0G")][ValidateNotNullOrEmpty()][String]$SiteCode,
[parameter(mandatory=$true,HelpMessage="Please, provide a location to import the CSV file from with the filename. e.g C:\Temp\YourCSV.csv")][ValidateNotNullOrEmpty()][String]$CSVin
)
#Import the ConfigurationManager.psd1 module 
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
#Set the current location to be the site code.
Set-Location "$SiteCode`:"

#$ErrorActionPreference= 'silentlycontinue'
#Get the content of the CSV file
$Computers = Import-Csv $CSVin

#Loop through each Device and perform actions
Foreach ($Computer in $Computers) {
    #Get Device Resource ID
    $ResourceID = (Get-CMDevice -name $($Computer.Name)).ResourceID
    #Add the Device to the Collection specified
    Write-Host "Adding Machine $($Computer.Name) ResourceID: $ResourceID" -ForegroundColor Yellow
    add-cmdevicecollectiondirectmembershiprule -CollectionId $CollectionID -resourceid $ResourceID -Verbose 

} 
#Set location of script back to script root.
Set-Location $PSScriptRoot

###########################################################################