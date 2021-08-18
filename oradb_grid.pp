class dbaas::oradb_grid 

{
  file { [  '/u01/sf_software/' ]:
            ensure =>  'directory',
       }
  file { "/u01/sf_software/grid.zip":
      mode => "440",
      owner => root,
      group => root,
      source => "puppet:///modules/dbaas/grid.zip",
      replace =>  'no', # this is the important property

  }
  exec { 'unzip':
    command     => '/usr/bin/unzip /u01/sf_software/grid.zip',
    cwd         => '/u01/sf_software/',
    user        => 'root',
    require     => File["/u01/sf_software/grid.zip"],
    #refreshonly => true,
  }
  file { "/u01/sf_software/install_oracle_grid.sh":
      mode => "775",
      owner => root,
      group => root,
      source => "puppet:///modules/dbaas/install_oracle_grid.sh",
      require  => Exec['unzip'],
  }
# set the swap ,forge puppet module petems-swap_file
swap_file::files { 'default':
    ensure => present,
    #    require  => Exec['/u01/sf_software/install_oracle_grid.sh'],
}
class { 'selinux':
   mode =>  'disabled'
}
 #  exec { 'install_grid':
  # command     => '/media/sf_software/install_oracle_grid.sh',
  # cwd         => '/media/sf_software/',
  # user        => 'root',
  # require     => File["/media/sf_software/install_oracle_grid.sh"],
  # refreshonly => true,
  #}

}
