#
# See the file "LICENSE" for the full license governing this code.
#
# Class: easy_type::license::available
#
# This class makes sure all the licenses installed on the server are available on all agents
# The modules from Enterprise Modules need them on the agents.
#
# The puppet_confdir fact contains the value of the Puppet setting confdir from the puppet.conf
# settings file. So this class copies all entitlemnets to the puppet config directory.
#
class easy_type::license::available(
  $server = '',
  $path   = 'em_license'
) {

  easy_type::debug_evaluation()

  unless defined(File["${facts['puppet_confdir']}/${path}"]) {
    file { "${facts['puppet_confdir']}/${path}":
      ensure  => 'directory',
      source  => "puppet://${server}/modules/${path}",
      path    => "${facts['puppet_confdir']}/${path}",
      recurse => true,
      purge   => true,
    }
  }
}
