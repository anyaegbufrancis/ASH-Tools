function Edit-iDRAC {
    PROCESS {  
        $user = $var_files.idrac_old
        $root_password = $var_files.idrac_old
        foreach( $su in $var_files.idrac ){
            try {
                # Configure SNMPv3 for Hardware Monitoring
                 Write-Host "Updating SNMPv3 Settings on $su..." -ForegroundColor Green
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.IpmiLanPrivilege 15
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.IpmiSerialPrivilege 15
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.Enable 1
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.AuthenticationProtocol SHA
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.PrivacyProtocol AES
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.SNMPv3Enable Enabled
                 racadm -r $su -u $user -p $root_password set iDRAC.Users.3.ProtocolEnable Enabled
                 racadm -r $su -u $user -p $root_password set iDRAC.IPMILan.CommunityName public
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.Alert.1.SNMPv3Username $user
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.AgentCommunity public
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.TrapFormat SNMPv3
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.Alert.2.DestAddr $var_files.pep_ip
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.Alert.3.DestAddr $var_files.pep_ip2
                 racadm -r $su -u $user -p $root_password set idrac.SNMP.Alert.4.DestAddr $var_files.pep_ip3
                 Write-Host "Updating SNMPv3 Settings on $su Completed..." -ForegroundColor Green
            }
            catch {
                $ErrorOutput = $_
                Write-Host $user
                Write-Host $root_password
                Write-Warning -Message "Host $su Failed..."
                $ErrorOutput | Out-File -File $idrac_file".txt" -Append
            }
            racadm -r $var_files.idrac[0] -u $user -p $root_password eventfilters test -i CPU0003
            racadm -r $var_files.idrac[1] -u $user -p $root_password eventfilters test -i CPU0003

        }            
            
        }
}