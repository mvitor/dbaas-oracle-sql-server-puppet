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
  #$puppet_download_mnt_point = "/software",
  $puppet_download_mnt_point = "puppet:///modules/oradb" ,
  $ee_options_selection      = false,
  $ee_optional_components    = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  $create_user               = undef,
  $user = "oracle" ,
  $cdb_name = 'CDB',
  $oracle_user = "oracle",
)
{
  #  Class['::oradb::installdb_unisys'] -> Class['::oradb::database_unisys'] -> Class['oradb::listener_unisys'] -> Class['oradb::database_pluggable_unisys']->Class['::dbaas::oracle_archivelog']


# declare additional run stage
    stage { 'stage01': }
    stage { 'stage02': }
    stage { 'stage03': }
    stage { 'stage04': }
    stage { 'stage05': }
    stage { 'stage06': }
    Stage['stage01'] ->Stage['stage02'] ->Stage['stage03'] ->Stage['stage04'] -> Stage['stage05'] ->Stage['stage06'] ->Stage['main'] 
class { '::oradb::installdb_unisys':
  #oradb::installdb{ '12.1.0.1_Linux-x86-64':
  #    stage => 'pre',
    stage => 'stage01',
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
 
include ::oradb::installdb_unisys
  #  oradb::database{'database_creation':
class { 'oradb::database_unisys':
    stage   =>  'stage02',
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
include ::oradb::database_unisys
class {'oradb::listener_unisys':
  #db_listener{ 'startlistener':
        stage => 'stage03',
        oracle_home             => $oracle_home,
        action       => 'running',
        # }
}
include ::oradb::listener_unisys
class {'oradb::tnsnames_unisys' : 
  oracle_home                                                                              => $oracle_home,
  user                                                                                     => 'oracle',
  #title                                                                                    => 'CDB',
  group                                                                                    => 'dba',
  server               => { myserver => { host => '192.168.32.7', port => '1521', protocol => 'TCP' }},
  connect_service_name                                                                     => 'CDB',
  stage                                                                                    => 'stage04',
  #require                                                                                 => Oradb::Dbactions['start oraDb'],
}
include ::oradb::tnsnames_unisys
  #oradb::database_pluggable{'pdb_creation':
class {'oradb::database_pluggable_unisys':
    oracle_home_dir          => $oracle_home,
    pdb_name                 => "PDB1",
    user                     => $user,
    source_db                => $cdb_name,
    pdb_datafile_destination => "/u01/oracle/oradata/PDB1",
    pdb_admin_password       => $pdb_admin_password,
    log_output               => true,
    stage => 'stage05',
}
include ::oradb::database_pluggable_unisys

}


