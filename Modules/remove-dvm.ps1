function Remove-DVM {
    PROCESS {
            try {
                $vmname = $var_files.dvm_name
                $vm = Get-VM -VMName $vmname
                $vhdPaths = @()
                $vhdDisks = Get-VMHardDiskDrive -VMName $VM.name
                $vhdPaths += $vhdDisks.Path
                $dvdDisks = get-vmdvddrive -VMName $VM.Name
                $vhdPaths += $dvdDisks.Path
                $vmPath = $vm.Path
                Remove-VM -VMName $VMName -Force
                foreach ($vhdPath in $vhdPaths) {
                    if ($vhdPath) {
                        Remove-Item -Path $vhdPath -Force 
                    }
                }
                $ArtifactsDirectory = Join-Path -Path $vmPath -ChildPath $VMName if (Test-Path -Path $ArtifactsDirectory)
                {
                    Remove-Item -Path $ArtifactsDirectory -Recurse -Force 
                }
                
            }
            catch {
                Write-Warning -Message "Removal of DVM  failed..."
            }
        }
}
