#
# See the file "LICENSE" for the full license governing this code.
#
# Class: easy_type::license::mount
#
# Add an extra Puppet file server mount point including
# the entitlements.yml file 
#
class easy_type::license::mount(
  $path         = 'em_license',
  $puppet_user  = 'pe-puppet',
  $puppet_group = 'pe-puppet',
) {
  $defaults = {
    ensure            => 'present',
    path              => "${facts['puppet_confdir']}/fileserver.conf",
    section           => $path,
    key_val_separator => ' ',
  }

  easy_type::debug_evaluation()

  unless defined(File["${facts['puppet_confdir']}/${path}"]) {
    file {"${facts['puppet_confdir']}/${path}":
      ensure => 'directory',
      owner  => $puppet_user,
      group  => $puppet_group,
      mode   => '0744',
    }
  }

  ini_setting { '[em_license] path':
    setting => 'path',
    value   => "${facts['puppet_confdir']}/${path}",
    *       => $defaults,
  }

  ini_setting { '[em_license] allow':
    setting => 'allow',
    value   => '*',
    *       => $defaults,
  }
}
