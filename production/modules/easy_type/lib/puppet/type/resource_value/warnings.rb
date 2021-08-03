#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:warnings) do
  include EasyType
  include EasyType::Mungers::Boolean

  desc <<-DESC
    Do emmit warnings when catalog items are changed.

    When `allow_redefine` is set to `true` you may override a current value in the catalog. It will however
    emit an warning by default. When you don't want the warning, you can suppress it by setting `warning` to `false`.

    **WARNING** This must be used with great care. It might unkowningly redefine a property value, without
    you nowing about it.

  DESC

  defaultto true
end
