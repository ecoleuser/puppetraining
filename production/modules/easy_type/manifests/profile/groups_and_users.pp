#++--++
#--++--
define easy_type::profile::groups_and_users(
  String[1] $calling_class,
) {
  $users           = lookup("${calling_class}::users", Hash)
  $user_defaults   = lookup("${calling_class}::user_defaults", Hash, 'first', { 'ensure' => 'present'})
  $groups          = lookup("${calling_class}::groups", Hash)
  $group_defaults  = lookup("${calling_class}::group_defaults", Hash, 'first', { 'ensure' => 'present'})
  $required_values = lookup("${calling_class}::required_values", Array[Optional[String[1]]], 'first', [])

  #
  # We use lookups and/or aliases in the yaml file for the passwords. This generates empty values
  # when the value is not available in hiera. This is what we DON'T want. So that is whe we do an extra lookup here.
  #
  $required_values.each |$required_value| {
    lookup($required_value)
  }

  easy_type::debug_evaluation()

  if $groups.size > 0 {
    $groups_list = $groups.keys
    echo {"Ensure Group(s) ${groups_list.join(',')}":
      withpath => false,
    }
  }

  if $users.size > 0 {
    $users_list = $users.keys
    echo {"Ensure User(s) ${users_list.join(',')}":
      withpath => false,
    }
  }
  #
  # If a password is provided, hash it and use it.
  #
  $modified_user_list = $users.map |$user, $settings| {
    if $settings['password'] {
      if $settings['password'][0] == '$' {
        debug "because password for ${user} start's with a '$' we infer it is already hashed..."
        [ $user, $settings ]
      } else {
        debug "Hashing specified password for ${user}..."
        [$user, $settings.merge({'password' => pw_hash($settings['password'], 'SHA-512', regsubst($::macaddress,':','','G'))})]
      }
    }
  }
  ensure_resources('user', Hash.new($modified_user_list), $user_defaults)
  ensure_resources('group', $groups, $group_defaults)
}
