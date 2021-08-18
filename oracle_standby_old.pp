class dbaas::oracle_primary (
  #  $sql_user = undef,
  #$version               = hiera('profiles::dbserver::version')
  $version = "12.1.0.1",
  $short_version = "12.1",
  $file = "linuxamd64_12102_database",
  $database_type             = 'EE',
  $ora_inventory_dir         = undef,
  $oracle_base               = "/u01/oracle",
  $oracle_home               = "/u01/oracle/product/12.1/db",
  $data_file_destination     = "/u01/oracle/oradata",
  $puppet_download_mnt_point = "/software",
  $ee_options_selection      = false,
  $ee_optional_components    = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  $create_user               = undef,
  $user = "oracle" ,
  $cdb_name = 'CDB',


)
{

oradb::installdb{ '12.1.0.1_Linux-x86-64':
  #    stage => 'pre',
    version => '12.1.0.1',
    database_type             => "EE",
    file                      => $file,
    create_user               => true,
    user                      => $oracle_user,
    download_dir              => $download_dir,
    puppet_download_mnt_point => $puppet_download_mnt_point,
    oracle_base               => $oracle_base,
    oracle_home               => $oracle_home,
  }
oradb::database{'database_creation':
    download_dir              => $download_dir,
    puppet_download_mnt_point => $puppet_download_mnt_point,
    oracle_base               => $oracle_base,
    oracle_home               => $oracle_home,
    data_file_destination     => $data_file_destination,
    user                      => $oracle_user,
    db_name                  => $cdb_name,
    container_database        => true,
    version                   => $short_version,
    memory_percentage         => "60",
    memory_total              => "1100",
    action                  => 'create',
  }

db_listener{ 'startlistener':
        oracle_home_dir             => $oracle_home,
        ensure       => 'running',
   }

oradb::database_pluggable{'pdb_creation':
    oracle_home_dir          => $oracle_home,
    pdb_name                 => "PDB1",
    user                     => $user,
    source_db                => $cdb_name,
    pdb_datafile_destination => "/u01/oracle/oradata/PDB1",
    pdb_admin_password       => $pdb_admin_password,
    log_output               => true,
}

# CREATE SUBROUTINE HERE
#function dbaas::oracle::set_archivelog_mode {
  db_control{'instance stop':
      ensure                  => 'stop', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }
  db_control{'instance mount':
      ensure                  => 'mount', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }
   ora_exec{"alter database archivelog":}

   db_control{'instance start 1':
      ensure                  => 'start', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }
  db_control{'instance stop 2':
      ensure                  => 'stop', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }

   db_control{'instance start 2':
      ensure                  => 'start', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }

# CREATE SUBORUTINE HERE
  ora_init_param{ 'SPFILE/db_name@CDB':
    ensure => 'present',
    value  => $cdb_name,
  }
  ora_init_param{ 'SPFILE/db_unique_name@CDB':
    ensure => 'present',
    value  => $cdb_name,
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_CONFIG@CDB':
    ensure => 'present',
    value  => "DG_CONFIG=($cdb_name, $cdb_name_stdby)",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_DEST_1@CDB':
    ensure => 'present',
    value  => "LOCATION=$data_file_destination\archivelog VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=$cdb_name",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_DEST_2@CDB':
    ensure => 'present',
    value  => "SERVICE=$cdb_name_stdby LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=$cdb_name_stdby",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_DEST_STATE_1@CDB':
    ensure => 'present',
    value  => "ENABLE",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_DEST_STATE_2@CDB':
    ensure => 'present',
    value  => "ENABLE",
  }
  ora_init_param{ 'SPFILE/REMOTE_LOGIN_PASSWORDFILE@CDB':
    ensure => 'present',
    value  => "EXCLUSIVE",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_FORMAT@CDB':
    ensure => 'present',
    value  => "%t_%s_%r.arc",
  }
  ora_init_param{ 'SPFILE/LOG_ARCHIVE_MAX_PROCESSES@CDB':
    ensure => 'present',
    value  => '30',
  }
# Standby role parameters --------------------------------------------------------------------
  ora_init_param{ 'SPFILE/fal_server@CDB':
    ensure => 'present',
    value  => 'CDB_STBY',
  }
  ora_init_param{ 'SPFILE/standby_file_management@CDB':
    ensure => 'present',
  }
  ora_init_param{ 'SPFILE/db_file_name_convert@CDB':
    ensure => 'present',
    value  => "CDB_STBY','CDB",
  }
  ora_init_param{ 'SPFILE/log_file_name_convert@CDB':
    ensure => 'present',
    value  => "CDB_STBY','CDB",
 }

   db_control{'instance stop 3':
    ensure                  => 'stop', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }

   db_control{'instance start 3':
      ensure                  => 'start', #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
    }

}
