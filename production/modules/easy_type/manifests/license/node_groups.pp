#
# See the file "LICENSE" for the full license governing this code.
#
# Class: easy_type::license::node_groups
#
# Create the base node groups required for node group based licenses
#
class easy_type::license::node_groups(
  Array[String[1]] $modules,
) {
  if defined(Node_group) {
    node_group { 'EM licensed nodes':
      ensure => 'present',
      parent => 'All Nodes',
    }
    $modules.each |$module_name| {
      node_group { $module_name:
        ensure => 'present',
        parent => 'EM licensed nodes',
      }
    }

  } else {
    notice 'Skipping node group definition because module WhatsARanjit-node_manager is not installed.'
  }
}
