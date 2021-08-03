    class { 'fmw_domain':
      version                       => '12.2.1',
      java_home_dir                 => '/usr/java/jdk1.8.0_301',
      middleware_home_dir           => '/opt/oracle/middleware',
      weblogic_home_dir             => '/opt/oracle/middleware/wlserver',
      domains_dir                   => '/opt/oracle/middleware/user_projects/domains',
      apps_dir                      => '/opt/oracle/middleware/user_projects/applications',
      domain_name                   => 'base_domain',
      weblogic_password             => 'Welcome01',
      adminserver_listen_address    => '139.59.95.8',
      nodemanager_listen_address    => '139.59.95.8',
      soa_suite_cluster             => 'soa_cluster',
      soa_suite_install_type        => 'BPM',
      repository_database_url       => 'jdbc:oracle:thin:@139.59.82.5:1539/pdb1',
      repository_prefix             => 'DEV3',
      repository_password           => 'Welcome02',
    }

    class { 'fmw_domain::domain':
      nodemanagers => [ { "id" => "node1",
                          "listen_address" => "139.59.82.5"
                        }],
      servers      =>  [
        { "id"             => "soa12c_server1",
          "nodemanager"    => "node1",
          "listen_address" => "139.59.82.5",
          "listen_port"    => 8001,
          "arguments"      => "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
        },
        { "id"             => "soa12c_server2",
          "nodemanager"    => "node1",
          "listen_address" => "139.59.82.5",
          "listen_port"    => 8002,
          "arguments"      => "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
      }],
     clusters      => [
        { "id"      => "soa_cluster",
          "members" => ["soa12c_server1","soa12c_server2"]
        }
        ],
    }

    Class['fmw_domain::extension_soa_suite'] ->
            Class['fmw_domain::nodemanager'] ->
              Class['fmw_domain::adminserver']

    include fmw_domain::extension_soa_suite
    include fmw_domain::nodemanager
    include fmw_domain::adminserver

