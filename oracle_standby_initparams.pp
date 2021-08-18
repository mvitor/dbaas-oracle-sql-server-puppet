class dbaas::oracle_standby_initparams (

    $oracle_home               = "/u01/oracle/product/12.1/db",
    $mount_flag = "/tmp/shutdown_to_mount.flg",
    $cdb_name = 'CDB',
    $cdb_name_stdby = 'CDB_Standby',
)
{

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
    value  => "DG_CONFIG=($cdb_name,$cdb_name_stdby)",
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
    value  =>  'auto',
  }
  ora_init_param{ 'SPFILE/db_file_name_convert@CDB':
    ensure => 'present',
    #value  => "CDB','CDB_STBY",
    value  => "CDB_STBY','CDB",
  }
  ora_init_param{ 'SPFILE/log_file_name_convert@CDB':
    ensure => 'present',
    value  => "CDB_STBY','CDB",
    #value  => "CDB','CDB_STBY",
 }
  ora_exec{"  shutdown immediate":
            unless => "select * from v\$parameter where upper(NAME)=\'LOG_ARCHIVE_CONFIG\' AND VALUE=\'DG_CONFIG=(${cdb_name},${cdb_name_stdby})\'"}


    db_control{'instance start 3':
      ensure                  => 'running' , #running|start|abort|stop
      instance_name           =>  $cdb_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => 'oracle',
      #      refreshonly             =>  true,
    }



}
