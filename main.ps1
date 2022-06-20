
$global:var_files = Get-Content '.\details.json' | Out-String | ConvertFrom-Json
$global:File_Success = "Logs/TestAzureStack_Success"
$global:File_test_error = "Logs/TestAzureStack_Error.log"
$global:Registration = "Logs/Registration"    
$global:Registration_error = "Logs/Registration_error"
$global:connect_azure = "Logs/connect_azure"
$global:KeyOutputFilePath = "ActivationKey.txt"
$global:moduleName = '.\AzureStack-Tools-az\Registration\RegisterWithAzure.psm1'
$global:FilePathForRegistrationToken = "RegistrationToken.txt"
$global:stampInfo = "Logs/StampInfo"
$global:CloudID = "CloudID.txt"
$global:thiserror = "Logs/stampInfo_error"      
$global:idrac_file = "../Logs/idrac_log"

### Key Functions ###
# Tests AZS 
# CloudID
# Completes Registration for Connected and disconnected
# Removes DVM
# Configures SNMPv3 on Servers's iDRAC
# Create Accounts on HLH and MGMT-VM

. .\Modules\accounts-creation.ps1 # account creationn call
. .\Modules\snmv3-setting.ps1 # importing smv3 hw monitoring
. .\Modules\remove-dvm.ps1 #remove dvm
. .\Modules\test-azurestack.ps1 # test azure stack
. .\Modules\get-cloudid.ps1 # grab stamp cloudid
. .\Modules\register-azurestack.ps1 # Register Azure Stack to Azure


Write-Host "`nWELCOME TO AZURE STACK HUB POST INSTALL MAIN MENU:`n" -ForegroundColor Green
Write-Host "How do YOU want to Proceed?`n" -ForegroundColor Green
[int]$userMenuChoice = 0
while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 7){
    Write-Host "1. Test Azure Stack" -ForegroundColor Magenta
    Write-Host "2. Collect Stamp Cloud ID" -ForegroundColor Magenta
    Write-Host "3. Register Azure Stack Hub" -ForegroundColor Magenta
    Write-Host "4. Create Accounts on HLH and/or MGMT-VM" -ForegroundColor Magenta
    Write-Host "5. Remove DVM" -ForegroundColor Magenta
    Write-Host "6. Configure SNMPv3 on iDRACs" -ForegroundColor Magenta
    Write-Host "7. Quit and Exit" -ForegroundColor Magenta
[int]$userMenuChoice = Read-Host "`n:"}
switch ($userMenuChoice) {
    1 { Test-AzureStackMain }
    2 { Get-StampInfo }
    3 { Register-Start }
    4 { CreateAccounts }
    5 { Remove-DVM }
    6 { Edit-iDRAC }
    7 { QuitAndExit }
default {Write-Host "Nothing selected"}
}




