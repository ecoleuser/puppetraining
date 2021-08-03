#++--++
#--++--
define easy_type::profile::resources(
  String[1] $calling_class,
) {
  $resource_type  = lookup("${calling_class}::resource_type", String[1])
  $basic_message  = lookup("${calling_class}::message", String[1], undef, "Ensure ${resource_type}(s) for ${calling_class}")
  $list           = lookup("${calling_class}::list", Hash)

  easy_type::debug_evaluation()

  if $list.keys.size < 10 {
    $message = "${basic_message}: ${list.keys.join(',')}"
  } else {
    $message = $basic_message
  }
  if $list.keys.size > 0 {
    echo {$message:
      withpath => false,
    }
  }
  ensure_resources($resource_type, $list)
}
