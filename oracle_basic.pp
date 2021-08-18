class dbaas::oracle (
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
  $cdb_name = 'CDB1',


)
{
  #stage { 'pre': before =>  Stage["main"],
  # REmoving so far
  #}


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
}

