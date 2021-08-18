class dbaas::oracle_archivelog (

    $oracle_home               = "/u01/oracle/product/12.1/db",
    $mount_flag = "/tmp/shutdown_to_mount.flg",
    $cdb_name = 'CDB',
    $cdb_name_stdby = 'CDB_Standby',
)
{
  #ora_exec{"spool ${mount_flag}@{$cdb_name}":
  ora_exec{"spool ${mount_flag}":
             unless    => "select * from v\$database where LOG_MODE=\'ARCHIVELOG\'",
              logoutput => true,
                    }

# CREATE SUBROUTINE HERE
file { $mount_flag:
       ensure => present,
         notify                    => Exec[ 'start_mount_mode' ],
        content => 'foobar',
        #mode => '666',
     }
 exec { 'start_mount_mode':
  command      => "${oracle_home}/bin/sqlplus /nolog <<-EOF
                  connect / as sysdba
                  shutdown immediate;
                  startup mount;
                  alter database archivelog;
                  alter database open;
                  EOF",
  environment  => [ "ORACLE_HOME=${oracle_home}", "ORACLE_SID=$cdb_name",
                   "LD_LIBRARY_PATH=${oracle_home}/lib"],
  logoutput    => true,
  user         => 'oracle',
  onlyif       => "/bin/test -f ${mount_flag}",
  refreshonly  => true,
  }
}
