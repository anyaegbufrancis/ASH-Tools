function ConnectedSelected {
    $global:deploymentMode = "Connected"
}

function DisConnectedSelected {
    $global:deploymentMode = "Disconnected"
}
function PayAsYouGo {
    $global:billingModel = "PayAsYouUse"
    $global:UsageReportingEnabled = $true
}
function Capacity {
    $global:billingModel = "Capacity"
    $global:UsageReportingEnabled = $false
}

function QuitAndExit {
    Write-Host "Exiting Script..." -ForegroundColor Yellow
    Exit
}

function BillingQuery {
    ### Select Billing Mode ###
    Write-Host "`nBILLING MODE:`n"
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 3){
        Write-Host "1. PAY AS YOU GO Mode" -ForegroundColor Magenta
        Write-Host "2. CAPACITY Mode" -ForegroundColor Magenta
        Write-Host "3. Quit and Exit" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease SELECT your BILLING Mode:`n"}
    switch ($userMenuChoice) {
        1{ PayAsYouGo }
        2{ Capacity }
        3{ QuitAndExit }
    default {Write-Host "Nothing selected"}
    }
}
function DeploymentMode {
    ### Select Deployment Mode ###
    Write-Host "`nDEPLOYMENT MODE:`n"
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 3){
        Write-Host "1. CONNECTED" -ForegroundColor Magenta
        Write-Host "2. DISCONNECTED" -ForegroundColor Magenta
        Write-Host "3. Quit and Exit" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease SELECT your DEPLOYMENT Mode:`n"}
    switch ($userMenuChoice) {
        1{ ConnectedSelected; BillingQuery }
        2{ DisConnectedSelected; Capacity }
        3{ QuitAndExit }
    default {Write-Host "Nothing selected"}
    }
}

function CredentialSource {
    ### Select Deployment Mode ###
    Write-Host "`nCREDENTIAL SOURCE:`n"
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 3){
        Write-Host "1. Use Credentials Given by Customer" -ForegroundColor Magenta
        Write-Host "2. Customer to ENTER Credentials" -ForegroundColor Magenta
        Write-Host "3. Quit and Exit" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease SELECT CREDENTIAL SOURCE:`n"}
    switch ($userMenuChoice) {
        1{ PreSupplied }
        2{ CustomerToEnter }
        3{ QuitAndExit }
    default {Write-Host "Nothing selected"}
    }
}

function PreSupplied {
    try {
        ##Connecting to Azure with hard coded credentials###
        Write-Host "`nConnecting Using hardcoded credentials" -ForegroundColor Magenta
        $pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.account_password
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $var_files.account_username,$pw
        Connect-AzAccount -EnvironmentName $var_files.environment -Credential $cred | Out-File -File $connect_azure".log"
    }
    catch {
        Write-Host "Login Failed..." -ForegroundColor Magenta
        Exit
    }
    
}
function CustomerToEnter {
    try {
        ##Connecting to Azure with customer entered credentials
        Write-Host "Please, Enter Credential in browser" -ForegroundColor Magenta
        Connect-AzAccount -EnvironmentName $var_files.environment | Out-File -File $connect_azure".log"
    }
    catch {
        Write-Host "Login Failed..." -ForegroundColor Magenta
        Exit
    }
    
}

function Register-Token {
    PROCESS {
        if ( Test-Connection -ComputerName $var_files.pep_ip -Quiet ) {
            ###Accepting PEP credentials from variable###
            $winrm = -join("winrm s winrm/config/client '@{TrustedHosts= ",'"',$var_files.pep_ip,'"',"}'")
            $winrm
            Set-Item wsman:\localhost\Client\TrustedHosts -Value $var_files.pep_ip -Concatenate
            $pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.pep_password
            $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $var_files.pep_username,$pw
             
            ### Collecting Registration Token from Stamp ###
            Write-Host "Collecting Registration Token for Disconnected Azure Stack" -ForegroundColor Green
            Get-AzsRegistrationToken -PrivilegedEndpointCredential $cred -PrivilegedEndpoint $var_files.pep_ip -BillingModel $billingModel -UsageReportingEnabled: $UsageReportingEnabled -AgreementNumber $var_files.ea_number -TokenOutputFilePath $FilePathForRegistrationToken  
            Write-Host "`nStamp Registration Token saved in $FilePathForRegistrationToken" -ForegroundColor Green
        }
        else {
            Write-Host "`nPEP cannot be reached on : "$var_files.pep_ip -ForegroundColor Red
            Write-Host "`nPlease Establish Connectivity to Azure Stack Hub`n" -ForegroundColor Red
            Exit
        }
    }
}

function Register-DASH {
    PROCESS {
        if ( Test-Connection -ComputerName "www.microsoft.com" -Quiet ) {
            Import-Module $global:moduleName
            ## Registration of ASH ##
            Write-Host "`nStarting Disconnected Azure Stack Hub Registration`n" -ForegroundColor Green
            $RegistrationName = $var_files.registrationName
            Register-AzsEnvironment -RegistrationToken (Get-Content -Path "../RegistrationToken") -RegistrationName $RegistrationName | Out-File -File $Registration".log"
            Get-AzsActivationKey -RegistrationName $RegistrationName -KeyOutputFilePath $KeyOutputFilePath 
        }
        else {
            Write-Host "`nDisconnected Azure Stack Hub Registration Failed...`n" -ForegroundColor Red
            Exit
        }
    }
}

function CoreMain {
    ### Add PEP IP to Trusted Hosts List ###
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $var_files.pep_ip -Force -Concatenate -ErrorAction Stop
    Write-Host "`nStarting Azure Stack Registration Script...`n" -ForegroundColor Green
    ##Collect Input based on Azure Stack Ddployment Details##
    DeploymentMode
    Write-Host @"
                SELECTED OPTIONS:
                Deployment Mode: $deploymentMode 
                Billing Mode: $billingModel
                Usage Reporting: $UsageReportingEnabled
"@ -ForegroundColor Green
    Write-Host "`nAccept Values & Continue?:`n"
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 2){
        Write-Host "1. YES" -ForegroundColor Magenta
        Write-Host "2. NO" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease SELECT your DEPLOYMENT Mode:`n"}
    switch ($userMenuChoice) {
        1{ Write-Host "You have chosen to continue with entered parameters" -ForegroundColor Green }
        2{ Write-Host "You have chosen to abort" -ForegroundColor Red; return }
    default { Write-Host "Nothing selected"}
    }

    CredentialSource
    
    ## Registration Preparation ###
    Register-AzResourceProvider -ProviderNamespace Microsoft.AzureStack
    Write-Host "Importing Module..." -ForegroundColor Magenta
    Import-Module $moduleName
    
    ###Accepting PEP credentials from variable###
    $pep_pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.pep_password
    $pep_cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $var_files.pep_username,$pep_pw
    
    if ( $deploymentMode -eq "Connected") {
        ### Starting Azure Stack Hub Registrion for Stamp in Connected Mode ###
        Write-Host "Starting 'Connected' Azure Stack Hub Registration" -ForegroundColor Green
        Set-AzsRegistration -PrivilegedEndpointCredential $pep_cred -PrivilegedEndpoint $var_files.pep_ip -BillingModel $billingModel -RegistrationName $var_files.registrationName -UsageReportingEnabled: $UsageReportingEnabled | Out-File -File $Registration".log"
    } else {
        try {
            ## Check Connection to ASH and Generate Registration Token if Connected ##
            Write-Host "`nConnected to ASH?:`n"
            [int]$userMenuChoice = 0
            while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 2){
                Write-Host "1. YES" -ForegroundColor Magenta
                Write-Host "2. NO" -ForegroundColor Magenta
            [int]$userMenuChoice = Read-Host "`nPlease SELECT:`n"}
            switch ($userMenuChoice) {
                1{ Register-Token; Register-DASH }
                2{ Write-Host "Please Connect to ASH and retry" -ForegroundColor Red; return }
            default { Write-Host "Nothing selected"}
            }    
        }
        catch {
            $ErrorOutput = $_
            Write-Warning -Message "Registration of Disconnected ASH Failed"
            $ErrorOutput | Out-File -File $Registration_error".log"
        }
                   
    }

}

function Register-Start {
    ### Select Deployment Mode ###
    Write-Host "`nIs AZ Powershell Module Installed & LanguageMode Set to 'FullLanguage'?" -ForegroundColor Magenta
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 2){
        Write-Host "1. YES" -ForegroundColor Magenta
        Write-Host "2. NO" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease Confirm Pre-Requisites:`n"}
    switch ($userMenuChoice) {
        1{ CoreMain }
        2{ Write-Host "`nPlease Install Azure Module with 'Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force'" -ForegroundColor Yellow;
        Write-Host "Ensure that'`$ExecutionContext.SessionState.LanguageMode' Returns 'FullLanguage' Before Continuing...`n" -ForegroundColor Yellow }        
    default {Write-Host "Nothing selected"}
    }
}
