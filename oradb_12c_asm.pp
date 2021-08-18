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
    #disk_discovery_string  => '/nfs_client/asm*',
    #disks                  => '/nfs_client/asm_sda_nfs_b1,/nfs_client/asm_sda_nfs_b2',
    disk_discovery_string =>  "ORCL:*",
    disks =>  "ORCL:DISK1,ORCL:DISK2",
    disk_redundancy        => 'EXTERNAL',
    remote_file            => true,
    puppet_download_mnt_point => $puppet_download_mnt_point,
  }

ora_asm_diskgroup{ 'RECO@+ASM':
    ensure          => 'present',
    au_size         => '1',
    compat_asm      => '11.2.0.0.0',
    compat_rdbms    => '10.1.0.0.0',
    diskgroup_state => 'MOUNTED',
    disks           => {'RECO_0000' => {'diskname' => 'RECO_0000', 'path' => '/nfs_client/asm_sda_nfs_b3'},
                        'RECO_0001' => {'diskname' => 'RECO_0001', 'path' => '/nfs_client/asm_sda_nfs_b4'}},
    redundancy_type => 'EXTERNAL',
    require         => Oradb::Opatch['19791420_db_patch_2'],
  }
ora_asm_diskgroup{ 'RECO@+ASM':
    ensure          => 'present',
    au_size         => '1',
    compat_asm      => '11.2.0.0.0',
    compat_rdbms    => '10.1.0.0.0',
    diskgroup_state => 'MOUNTED',
    disks           => {'RECO_0000' => {'diskname' => 'RECO_0000', 'path' => '/nfs_client/asm_sda_nfs_b3'},
                        'RECO_0001' => {'diskname' => 'RECO_0001', 'path' => '/nfs_client/asm_sda_nfs_b4'}},
    redundancy_type => 'EXTERNAL',
    require         => Oradb::Opatch['19791420_db_patch_2'],
  }
 }
