
function Get-StampInfo {
    PROCESS {
            try {
                Write-Host "Starting Info Collection`n" -ForegroundColor Green
                $winrm = -join("winrm s winrm/config/client '@{TrustedHosts= ",'"',$var_files.pep_ip,'"',"}'")
                $winrm
                $pw = ConvertTo-SecureString -AsPlainText -Force -String $var_files.pep_password
                $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $var_files.pep_username,$pw
                $session = New-PSSession -ComputerName $var_files.pep_ip -Credential $cred -ConfigurationName PrivilegedEndPoint -SessionOption (New-PSSessionOption -Culture en-US -UICulture en-US)
                Write-Host "Authentication Successful. Starting Remote Command`n" -ForegroundColor Green

                ### Collecting Stamp Cloud ID###
                Write-Host "`nCollecting Stamp CloudID..." -ForegroundColor Green
                $stampInfo = Invoke-Command -Session $session -ScriptBlock { Get-AzureStackStampInformation }  | Tee-Object -FilePath $stampInfo".log" -ErrorAction Stop
                $stampInfo.CloudID | Tee-Object -FilePath $CloudID -ErrorAction Stop

                #### Clean up PSSession ###
                $idleSession = Get-PSSession | Select-Object Id
                foreach ($id in $idleSession.Id) {Remove-PSSession $id}
            }
            catch {
                $ErrorOutput = $_
                Write-Host "`nTest-AzureStack Failed on PEP :"$var_files.pep_ip"`n" -ForegroundColor Yellow
                $ErrorOutput | Out-File -File $thiserror".log"
            }
        }
}
