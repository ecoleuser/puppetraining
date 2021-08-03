#++--++
#--++--
define easy_type::profile::limits(
  String[1] $calling_class,
) {
  $list           = lookup("${calling_class}::list", Hash)

  if $list.keys.size > 0 {
    echo {"Ensure Limit(s) for ${calling_class}: ${list.keys.join(',')}":
      withpath => false,
    }
  }

  easy_type::debug_evaluation()

  ensure_resources('limits::limits', $list)
}
