function CreateHLHAccount {
    ## Creating Accounts on HLH ###
    try {        
        Write-Host "Creating Accounts in HLH :" $var_files.machines[0] -ForegroundColor Magenta
        $account_pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.pw1  # change
        $account_cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist ".\HLHAdmin",$account_pw #change
        $session = New-PSSession -ComputerName $var_files.machines[0] -Credential $account_cred -ErrorAction Stop
        Write-Host "Authentication Successful. Starting Remote Command`n" -ForegroundColor Green    
        
        ### Creating Accounts on HLH ###
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account1, $acp, $var_files.fname1, $var_files.desc1, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Administrators", $var_files.account1
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account2, $acp, $var_files.fname2, $var_files.desc2, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Administrators", $var_files.account2 
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account3, $acp, $var_files.fname3, $var_files.desc3, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Guests", $var_files.account3 
        Invoke-Command -Session $session -ScriptBlock { Disable-LocalUser -Name $args[0] } -ArgumentList "HLHAdmin"

        Write-Host "Accounts created on HLH :" $var_files.machines[1] -ForegroundColor Magenta
    
        #### Clean up PSSession ###
        $idleSession = Get-PSSession | Select-Object Id
        foreach ($id in $idleSession.Id) {Remove-PSSession $id}
        Get-PSSession
        return
        }
        catch {
            Write-Host "Account Creation Failed on :" $var_files.machines[0] -ForegroundColor Yellow
        }
}

function CreateMGMTVMAccount {
    ## Creating Account in MGMT-VM
    try {        
        Write-Host "Creating Accounts in MGMT-VM :" $var_files.machines[1] -ForegroundColor Magenta
        $account_pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.password
        $account_cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist ".\Administrator",$account_pw
        $session = New-PSSession -ComputerName $var_files.machines[1] -Credential $account_cred -ErrorAction Stop
        Write-Host "Authentication Successful. Starting Remote Command`n" -ForegroundColor Green
    
        ### Creating Accounts on MGMT-VM ###
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account1, $acp, $var_files.fname1, $var_files.desc1, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Administrators", $var_files.account1
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account2, $acp, $var_files.fname2, $var_files.desc2, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Administrators", $var_files.account2 
        Invoke-Command -Session $session -ScriptBlock { New-LocalUser -Name $args[0] -Password $args[1] -FullName $args[2] -Description $args[3] -AccountNeverExpires:$args[4] -PasswordNeverExpires:$args[4] } -ArgumentList $var_files.account3, $acp, $var_files.fname3, $var_files.desc3, $true 
        Invoke-Command -Session $session -ScriptBlock { Add-LocalGroupMember -Group $args[0] -Member $args[1] } -ArgumentList "Guests", $var_files.account3 
        Invoke-Command -Session $session -ScriptBlock { Disable-LocalUser -Name $args[0] } -ArgumentList "Administrator"

        Write-Host "Accounts created on MGMT-VM :" $var_files.machines[1] -ForegroundColor Magenta
    
        #### Clean up PSSession ###
        $idleSession = Get-PSSession | Select-Object Id
        foreach ($id in $idleSession.Id) {Remove-PSSession $id}
        Get-PSSession
        return
        }
        catch {
            Write-Host "Account Creation Failed on :" $var_files.machines[1] -ForegroundColor Yellow
        }   
    }

function CreateAccounts {
    Write-Host "Create Account on HLH or MGMT-VM. Please Select:`n" -ForegroundColor Green
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $var_files.machines[0] -Force -Concatenate -ErrorAction Stop
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $var_files.machines[1] -Force -Concatenate -ErrorAction Stop

    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 3){
        Write-Host "1. Create Accounts on HLH" -ForegroundColor Magenta
        Write-Host "2. Create Accounts on MGMT-VM" -ForegroundColor Magenta
        Write-Host "3. Quit and Exit" -ForegroundColor Magenta

    [int]$userMenuChoice = Read-Host "`nPlease Select Server to Upgrade`n"}
    switch ($userMenuChoice) {
        1{ CreateHLHAccount }
        2{ CreateMGMTVMAccount }
        3{ QuitAndExit }
    default {Write-Host "Nothing selected"}
    }
}
