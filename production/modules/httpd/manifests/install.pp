class httpd::install inherits httpd {
package { 'httpd':
ensure => installed,
}
}
