class dbaas::sqlserver (
	$source_letter = 'Z:/',
  $sapwd = undef,
  $instance_name = 'MSSQLSERVER',
  $windows_user = undef,
  $windows_pwd = undef,
  #  $iso_files = 'SW_DVD9_SQL_Svr_Standard_Edtn_2014w_SP2_64Bit_English_MLF_X21-04422.ISO', 
  $iso_file = 'SQLServer.ISO', 
)

{

    stage { 'stage01': }
    stage { 'stage02': }

    Stage['stage01'] ->Stage['stage02'] ->Stage['main']
class {'dbaas::sqlserver_binaries':
    stage => 'stage01',
}

class {'dbaas::sqlserver_installation':
  stage => 'stage02',
}



}
