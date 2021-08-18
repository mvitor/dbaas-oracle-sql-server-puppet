# operating system settings for Database
class dbaas::oradb_os_grid {

  $groups = ['oinstall','dba' ,'oper','asmdba','asmoper','asmadmin' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 505, #500 is ec2-user
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
 

}
