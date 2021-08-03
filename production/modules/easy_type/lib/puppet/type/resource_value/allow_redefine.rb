#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:allow_redefine) do
  include EasyType
  include EasyType::Mungers::Boolean

  desc <<-DESC
    Allow redefinition of the property value.

    By default the `resource_value` doesn't allow you to override the value of a property. It
    just allows the aditional definition of a property not yet defined.

    When you set `allow_redefine` to `true`, this is allowed.

    **WARNING** This must be used with great care. It might unkowningly redefine a property value.
  DESC

  defaultto false
end
