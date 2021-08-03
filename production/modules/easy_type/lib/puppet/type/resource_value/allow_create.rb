#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:allow_create) do
  include EasyType
  include EasyType::Mungers::Boolean

  desc <<-DESC
    Allow creation of the resource if it is not yet in the catalog.

    By default the `resource_value` requires an existing entry in the catalog. When you
    set `allow_create` to `true`, when the catalog doesn't contain the resource,
    `resource_value` wil create it.

    To allow this, the resource must allow a creation with just the specfied parameter name.
  DESC

  defaultto false
end
