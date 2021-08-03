#
# See the file "LICENSE" for the full license governing this code.
#
# Class: easy_type::license::activate
#
# This class makes sure the EM licenses are activated at the right point during a Puppet run. Best thing is
# add this class in your site.pp. Because it makes sure the entitlements files are copied in the setup stage,
# the entitlements are available when the EM modules start their work.
#
class easy_type::license::activate(
  $activate_node_groups = false
)
{
  require 'stdlib'

  if $activate_node_groups {
    easy_type::activate_node_groups()
  }

  class{'::easy_type::license::available':
    stage => 'setup',
  }
}
