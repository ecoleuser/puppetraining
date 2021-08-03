#++--++
#
# easy_type::profile::firewall::firewalld
#
# @summary Open up ports using the firewalld firewall
# Here is an example:
#
# ```puppet
#   easy_type::profile::firewall::firewalld
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
define easy_type::profile::firewall::firewalld(
  String[1] $calling_class,
  Boolean $manage_service,
) {

  easy_type::debug_evaluation()

  contain ::firewalld
  $ports          = lookup("${calling_class}::firewalld::ports", Hash)
  $defaults = {
    ensure   => 'present',
    zone     => 'public',
    protocol => 'tcp'
  }

  ensure_resources('firewalld_port', $ports, $defaults)
}
