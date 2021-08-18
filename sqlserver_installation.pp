class dbaas::sqlserver_installation
(
  $instance_name = 'MSSQLSERVER',
  $windows_user = $facts['cmp_database_user'],
  $sapwd = $facts['cmp_db_password'],
  $windows_pwd = $facts['cmp_db_password'],
  $source_letter = 'Z:/',
)
{

  user {'windows_user':
      name      => $windows_user,
      ensure    => present,
      groups    => ['Users','Administrators'],
      password  => $windows_pwd,
      managehome => true,
  }
  sqlserver_instance{ $instance_name:
    source                 => $source_letter,
    security_mode          => 'SQL',
    sa_pwd                 => $sapwd,
    features               => ['SQL'],
    sql_sysadmin_accounts  => [$windows_user],
    windows_feature_source => 'C:\Windows\WinSxS',
    install_switches        => {
    'TCPENABLED'          => 1,
    'SQLBACKUPDIR'        => 'C:\\MSSQLSERVER\\backupdir',
    'SQLTEMPDBDIR'        => 'C:\\MSSQLSERVER\\tempdbdir',
    'INSTALLSQLDATADIR'   => 'C:\\MSSQLSERVER\\datadir',
    'INSTANCEDIR'         => 'C:\\Program Files\\Microsoft SQL Server',
    'INSTALLSHAREDDIR'    => 'C:\\Program Files\\Microsoft SQL Server',
    'INSTALLSHAREDWOWDIR' => 'C:\\Program Files (x86)\\Microsoft SQL Server',
  }
  }
sqlserver_features { 'Generic Features':
     source   => $source_letter,
      features =>  ['ADV_SSMS',  'SSMS'],
  }
}
