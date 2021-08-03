#++--++
#
# easy_type::profile::firewall::iptables
#
# @summary Open up ports for the iptables
# Here is an example:
#
# ```puppet
#   easy_type::profile::firewall::iptables
# ```
#
# @param [Boolean] manage_service
#    Using this setting you can specify if you want this module to manage the firewall service.
#    The default value is `true` and will make sure the firewall service is started and enabled.
#
# @param calling_class
#    Class calling the firewall.
#
#
#--++--
define easy_type::profile::firewall::iptables(
  String[1] $calling_class,
  Boolean $manage_service,
) {

  easy_type::debug_evaluation()

  $ports          = lookup("${calling_class}::iptables::ports", Hash)
  unless defined(Package['iptables']) {
    package {'iptables':
      ensure => 'present',
    }
  }

  $defaults = {
    ensure => 'present',
    action => 'accept',
    proto  => 'tcp'
  }

  ensure_resources('firewall', $ports, $defaults)

  if $manage_service {
    service { 'iptables':
        ensure    => true,
        enable    => true,
        hasstatus => true,
    }
  }
}
