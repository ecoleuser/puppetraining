class profile::jenkins::master (
  String $jenkins_port = '9091',
  String $java_dist    = 'jdk',
) {

  class { 'jenkins':
    configure_firewall => false,
    install_java       => false,
    port               => $jenkins_port,
    config_hash        => {
      'HTTP_PORT'    => { 'value' => $jenkins_port },
      'JENKINS_PORT' => { 'value' => $jenkins_port },
    },
  }

  class { 'java':
    distribution => $java_dist,
    before       => Class['jenkins'],
  }
}
