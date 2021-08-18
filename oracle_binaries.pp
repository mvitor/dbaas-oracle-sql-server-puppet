class dbaas::oracle_binaries (
)
{
 package { 'sshpass ':
       ensure =>  'installed',
         }
file { '/software':
    ensure => 'directory',
    owner  => 'root',
    mode   => '0766',
  }
exec { 'scp copy from binaries':
  command => "sshpass -p \"Admin@dbaaspupt\" scp -o StrictHostKeyChecking=no cmpdbaaspupt@puppetmaster:\"/install/linuxamd64_12102_database_1of2.zip /install/linuxamd64_12102_database_2of2.zip /install/p24701882_121010_Generic.zip /install/p6880880_122010_Linux-x86-64.zip /install/Orasetup.tar.gz\" \"/software\" ",
}

}


