class dbaas::sqlserver_binaries
(
$command = 'Install-WindowsFeature Net-Framework-Core -source C:\windows\WinSxS',
$iso_file = 'SQLServer.ISO',
)
{

file {"c:\\software\\SQLServer.iso":
        ensure =>  present,
        source => "puppet:///modules/sqlserver/$iso_file",
        replace =>  false,
}

mount_iso { 'C:\software\SQLServer.iso':
    drive_letter =>  'Z',
}
exec { 'dotnet':
    command =>  $command,
      provider =>  powershell,
}
}
