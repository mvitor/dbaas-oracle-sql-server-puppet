# operating system settings for Database
class dbaas::oradb_os_grid {

  $groups = ['oinstall','dba' ,'oper','asmdba','asmoper','asmadmin' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 500,
    gid         => 'oinstall',
    groups      => $groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => "/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group[$groups],
    managehome  => true,
  }
  # Add to bin
  file { '/etc/profile.d/append-oracle-path.sh':
          mode =>  '644',
          content =>  'PATH=$PATH:/usr/local/bin/',
  }


  $install = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
               'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64',
               'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
               'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64','libXtst.x86_64','unzip']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
     config => {
                '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                'nproc'  => { soft => '2048'   , hard => '16384',  },
                                'stack'  => { soft => '10240'  ,},},
                },
     use_hiera => false,
  }
 user { 'grid' :
  ensure      => present,
  uid         => 501,
  gid         => 'oinstall',
  groups      => ['oinstall','dba','asmadmin','asmdba','asmoper'],
  shell       => '/bin/bash',
  password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
  home        => "/home/grid",
  comment     => "This user grid was created by Puppet",
  require     => Group[$groups],
  managehome  => true,
}
 ####### NFS example
 file { '/home/nfs_server_data':
  ensure  => directory,
  recurse => false,
  replace => false,
  mode    => '0775',
  owner   => 'grid',
  group   => 'asmadmin',
  require =>  User['grid'],
}
 class { 'nfs::server':
  package => latest,
  service => running,
  enable  => true,
}
 nfs::export { '/home/nfs_server_data':
  options => [ 'rw', 'sync', 'no_wdelay','insecure_locks','no_root_squash' ],
  clients => [ "*" ],
  require => [File['/home/nfs_server_data'],Class['nfs::server'],],
}
 file { '/nfs_client':
  ensure  => directory,
  recurse => false,
  replace => false,
  mode    => '0775',
  owner   => 'grid',
  group   => 'asmadmin',
  require =>  User['grid'],
}
 mounts { 'Mount point for NFS data':
  ensure  => present,
  source  => 'nfs_hostserver:/home/nfs_server_data',
  dest    => '/nfs_client',
  type    => 'nfs',
  opts    => 'rw,bg,hard,nointr,tcp,vers=3,timeo=600,rsize=32768,wsize=32768,actimeo=0  0 0',
  require => [File['/nfs_client'],Nfs::Export['/home/nfs_server_data'],]
}
 exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520":
  user      => 'grid',
  group     => 'asmadmin',
  logoutput => true,
  unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b1",
  require   => Mounts['Mount point for NFS data'],
}
exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520":
  user      => 'grid',
  group     => 'asmadmin',
  logoutput => true,
  unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b2",
  require   => [Mounts['Mount point for NFS data'],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"]],
}
 exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b3 bs=1M count=7520":
  user      => 'grid',
  group     => 'asmadmin',
  logoutput => true,
  unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b3",
  require   => [Mounts['Mount point for NFS data'],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],],
}
 exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b4 bs=1M count=7520":
  user      => 'grid',
  group     => 'asmadmin',
  logoutput => true,
  unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b4",
  require   => [Mounts['Mount point for NFS data'],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],
                Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b3 bs=1M count=7520"],],
}
 $nfs_files = ['/nfs_client/asm_sda_nfs_b1','/nfs_client/asm_sda_nfs_b2','/nfs_client/asm_sda_nfs_b3','/nfs_client/asm_sda_nfs_b4']
 file { $nfs_files:
  ensure  => present,
  owner   => 'grid',
  group   => 'asmadmin',
  mode    => '0664',
  require => Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b4 bs=1M count=7520"],
}


}
