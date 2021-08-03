#++--++
#--++--
define easy_type::profile::sysctl(
  String[1] $calling_class,
) {
  $list           = lookup("${calling_class}::list", Hash)
  $defaults       = lookup("${calling_class}::defaults", Hash, 'first', { 'ensure' => 'present'})

  easy_type::debug_evaluation()

  if $list.keys.size > 0 {
    echo {"Ensure Sysctl param(s) for ${calling_class}: ${list.keys.join(',')}":
      withpath => false,
    }
  }
  ensure_resources(sysctl, $list, $defaults)
}
