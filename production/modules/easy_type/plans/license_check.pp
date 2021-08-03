#
# See the file "LICENSE" for the full license governing this code.
#
#++--++
#--++--
plan easy_type::license_check(
  TargetSpec $target,
) {
  if get_targets($target).length > 1 {
    fail_plan("${target} did not resolve to a single target")
  }

  $used_modules = ['easy_type', 'ora_install', 'profile', 'ora_profile', 'ora_config', 'oci_config', 'em_license']

  easy_type::em_prep($target)
  apply_prep($target, {'required_modules' => $used_modules })

  $result = apply($target, {'required_modules' => $used_modules, '_catch_errors' => true}) {
    ora_install {'check':
      ensure => 'present',
    }
  }
  $target_result = $result.first()
  if $target_result.error {
    fail_plan($target_result.error())
    $target_result.report['logs'].each |$log| {
      out::message("${log['source']}: ${log['message']}")
    }
  } else {
    $target_result.report['logs'].each |$log| {
      out::message("${log['source']}: ${log['message']}")
    }
  }
}
# lint:endignore
