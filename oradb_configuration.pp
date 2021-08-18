class dbass::oradb_configuration {
  require oradb_12c

   tablespace {'MY_TS':
     ensure                    => present,
     size                      => 100M,
     datafile                  => 'my_ts.dbf',
     logging                   => 'yes',
     bigfile                   => 'yes',
     autoextend                => on,
     next                      => 100M,
     max_size                  => 12288M,
     extent_management         => local,
     segment_space_management  => auto,
   }

   role {'APPS':
     ensure    => present,
   }

   oracle_user{'TESTUSER':
     ensure                    => present,
     temporary_tablespace      => 'TEMP',
     default_tablespace        => 'MY_TS',
     password                  => 'testuser',
     grants                    => ['SELECT ANY TABLE',
                                   'CONNECT',
                                   'RESOURCE',
                                   'APPS'],
     quotas                    => { "MY_TS" => 'unlimited'},
     require                   => [Tablespace['MY_TS'],
                                   Role['APPS']],
   }
}
