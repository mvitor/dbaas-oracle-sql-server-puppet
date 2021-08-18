class dbaas::oradb_12c
(
  $version = "12.1.0.1",
  $short_version = "12.1",
  $file = "linuxamd64_12102_database",
  $ora_inventory_dir         = undef,
  $oracle_base               = "/u01/oracle",
  $oracle_home               = "/u01/oracle/product/12.1/db",
  $data_file_destination     = "/u01/oracle/oradata",
  #$puppet_download_mnt_point = "/software",
  $puppet_download_mnt_point = "puppet:///modules/oradb" ,

  $template                  = undef,
  $template_seeded           = undef,
  $template_variables        = 'dummy=/tmp', # for dbt template
  $db_name                   = 'orcl',
  $db_domain                 = undef,
  $db_port                   = '1521',
  $sys_password              = 'Welcome01',
  $system_password           = 'Welcome01',
  $recovery_area_destination = undef,
  $character_set             = 'AL32UTF8',
  $nationalcharacter_set     = 'UTF8',
  $init_params               = undef,
  $sample_schema             = 'TRUE',
  $memory_percentage         = '40',
  $memory_total              = '800',
  $database_type             = 'MULTIPURPOSE', # MULTIPURPOSE|DATA_WAREHOUSING|OLTP
  $em_configuration          = 'NONE',  # CENTRAL|LOCAL|ALL|NONE
  $storage_type              = 'FS', #FS|CFS|ASM
  $asm_snmp_password         = 'Welcome01',
  $db_snmp_password          = 'Welcome01',
  $asm_diskgroup             = 'DATA',
  $recovery_diskgroup        = undef,
  $cluster_nodes             = undef, # comma separated list with at first the local and at second the remode host e.g. "racnode1,racnode2"
  $container_database        = false, # 12.1 feature for pluggable database

  $ee_options_selection      = false,
  $ee_optional_components    = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  $create_user               = undef,
  $cdb_name = 'CDB',
  $cdb_name_stdby = 'CDB_Standby',
  $mount_flag = "/tmp/shutdown_to_mount.flg",
  $oracle_user = "oracle",
)
{
  require dbaas::oradb_os
  oradb::installdb{ '12.1.0.2_Linux-x86-64':
      version                   => $version,
      file                      => $file,
      database_type             => 'EE',
      oracle_base               => $oracle_base,
      oracle_home               => $oracle_home,
      user_base_dir             => '/home',
      bash_profile              => false,
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => '/var/tmp/install',
      #remote_file               => false,
      puppet_download_mnt_point => $puppet_download_mnt_point,
    }

    oradb::net{ 'config net':
      oracle_home  => $oracle_home,
      version      => '12.1',
      user         => 'oracle',
      group        => 'dba',
      download_dir => "/var/tmp/install",
      require      => Oradb::Installdb['12.1.0.2_Linux-x86-64'],
    }

    oradb::listener{'start listener':
      oracle_base  => $oracle_base,
      oracle_home  => $oracle_home,
      user         => 'oracle',
      group        => 'dba',
      action       => 'start',
      require      => Oradb::Net['config net'],
    }

    oradb::database{ 'oraDb':
      oracle_base  => $oracle_base,
      oracle_home  => $oracle_home,
      version                   => '12.1',
      user                      => 'oracle',
      group                     => 'dba',
      download_dir              => "/var/tmp/install",
      action                    => 'create',
      db_name                   => 'orcl',
      db_domain                 => 'example.com',
      sys_password              => 'Welcome01',
      system_password           => 'Welcome01',
      data_file_destination     => "/u01/oracle/oradata",
      recovery_area_destination => "/u01/oracle/flash_recovery_area",
      character_set             => "AL32UTF8",
      nationalcharacter_set     => "UTF8",
      init_params               => "open_cursors=400,processes=200,job_queue_processes=2",
      sample_schema             => 'TRUE',
      memory_percentage         => "40",
      memory_total              => "800",
      database_type             => "MULTIPURPOSE",
      require                   => Oradb::Listener['start listener'],
    }

    oradb::dbactions{ 'start oraDb':
      oracle_home  => $oracle_home,
      user                    => 'oracle',
      group                   => 'dba',
      action                  => 'start',
      db_name                 => 'orcl',
      require                 => Oradb::Database['oraDb'],
    }
    oradb::tnsnames{'orcl':
      oracle_home                                                                                       => $oracle_home,
      user                                                                                              => 'oracle',
      group                                                                                             => 'dba',
      server               => { myserver => { host=>$facts['ipaddress_eth0'], port => '1521', protocol => 'TCP' }},
      connect_service_name                                                                              => 'orcl',
      require                                                                                           => Oradb::Dbactions['start oraDb'],
  }


    oradb::autostartdatabase{ 'autostart oracle':
      oracle_home  => $oracle_home,
      user                    => 'oracle',
      db_name                 => 'orcl',
      require                 => Oradb::Dbactions['start oraDb'],
    }

}

