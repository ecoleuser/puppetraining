class profile::docker (
  $docker_version = "present",
) {

  package { 'docker':
    ensure => present,
    version => $docker_version,
  }

}
