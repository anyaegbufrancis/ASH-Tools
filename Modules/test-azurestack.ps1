function Test-AzureStack {
    PROCESS {
            try {
                Write-Host "`nStarting Azure Stark Hub Test Script...`n" -ForegroundColor Green
                $winrm = -join("winrm s winrm/config/client '@{TrustedHosts= ",'"',$var_files.pep_ip,'"',"}'")
                $winrm
                $pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.pep_password
                $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $var_files.pep_username,$pw
                $session = New-PSSession -ComputerName $var_files.pep_ip -Credential $cred -ConfigurationName PrivilegedEndPoint -SessionOption (New-PSSessionOption -Culture en-US -UICulture en-US)
                Write-Host "`nStarting Remote Command...`n" -ForegroundColor Green

                ### Testing Azure Stack ###
                Invoke-Command -Session $session -ScriptBlock { Test-AzureStack } | Tee-Object -FilePath $File_Success".log" -ErrorAction Stop

                ### Clean up PSSession ###
                $idleSession = Get-PSSession | Select-Object Id
                foreach ($id in $idleSession.Id) {Remove-PSSession $id}
                Get-PSSession
            }
            catch {
                $ErrorOutput = $_
                Write-Host "`nTest-AzureStack Failed on PEP : "$var_files.pep_ip "`n" -ForegroundColor Yellow
                $ErrorOutput | Out-File -File $File_test_error
            }
        }
}


# netsh winhttp show proxy	
# netsh winhttp reset proxy

function Test-AzureStackMain {
    ### Select Deployment Mode ###
    Write-Host "`nIs AZ Powershell Module Installed & LanguageMode Set to 'FullLanguage'?" -ForegroundColor Magenta
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 2){
        Write-Host "1. YES" -ForegroundColor Magenta
        Write-Host "2. NO" -ForegroundColor Magenta
    [int]$userMenuChoice = Read-Host "`nPlease Confirm Pre-Requisites:`n"}
    switch ($userMenuChoice) {
        1{ Test-AzureStack }
        2{ Write-Host "`nPlease Install Azure Module with 'Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force'" -ForegroundColor Yellow;
        Write-Host "Ensure that'`$ExecutionContext.SessionState.LanguageMode' Returns 'FullLanguage' Before Continuing...`n" -ForegroundColor Yellow }        
    default {Write-Host "Nothing selected"}
    }
}



