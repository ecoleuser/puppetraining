#++--++
#
# easy_type::profile::firewall
#
# @summary This class contains the definition of the firewall settings.
# When you are using a Redhat flavored version lower then release 7, this module uses the `puppetlabs-firewall` module to manage the `iptables` settings. When using a version 7 or higher, the puppet module `crayfishx-firewalld` to manage the `firewalld daemon`.
#
# When these customizations aren't enough, you can replace the class with your own class. See [ora_profile::database](./database.html) for an explanation on how to do this.
#
# @param calling_class
#    Class calling the firewall.
#
#--++--
define easy_type::profile::firewall(
  String[1] $calling_class,
) {
  $manage_service = lookup("${calling_class}::manage_service", Boolean)

  easy_type::debug_evaluation()

  case  $::operatingsystem {
    'RedHat', 'CentOS', 'OracleLinux': {
      case ($::os['release']['major']) {
        '4','5','6': {
          easy_type::profile::firewall::iptables{ $calling_class:
            calling_class  => $calling_class,
            manage_service => $manage_service,
          }
        }
        '7', '8': {
          easy_type::profile::firewall::firewalld{ $calling_class:
            calling_class  => $calling_class,
            manage_service => $manage_service,
          }
        }
        default: { fail 'unsupported OS version when checking firewall service'}
      }
    }
    'Solaris', 'AIX':{
      warning 'No firewall rules added on Solaris.'
    }
    default: {
        fail "${::operatingsystem} is not supported."
    }
  }
}
