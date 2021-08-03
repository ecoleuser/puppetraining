class httpd::configure inherits httpd{
        file { '/etc/httpd/conf/httpd.conf':
                ensure => file,
                owner => 'root',
                group => 'root',
                mode => '0644',
        }
}

