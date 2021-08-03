class httpd::start inherits httpd{
 service { 'httpd':
 ensure     => running,
 enable     => true,
 hasstatus  => true,
 hasrestart => true,
 require => Package['httpd'],
 }
 }

