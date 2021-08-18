class dbaas::oradb_12c_asm  {
  oradb::installasm{ 'db_linux-x64':
    version                => "12.1.0.1",
    file                   => "linuxamd64_12102_grid",
    grid_type              => 'HA_CONFIG',
    grid_base              => "/u01/oracle/",
    grid_home              => "/u01/oracle/product/12.1/grid",
    ora_inventory_dir         => undef,
    user                      => 'grid',
    asm_diskgroup          => 'DATA',
    disk_discovery_string  => '/nfs_client/asm*',
    disks                  => '/nfs_client/asm_sda_nfs_b1,/nfs_client/asm_sda_nfs_b2',
    disk_redundancy        => 'EXTERNAL',
    remote_file            => false,
    puppet_download_mnt_point => $puppet_download_mnt_point,
  }
 }
