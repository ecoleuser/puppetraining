#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newproperty(:value, :array_matching => :all) do
  include EasyType
  include EasyType::Helpers

  desc <<-DESC
    The actual value you want the resource property to be set to.

    In the next example, you want to set the property `owner` to the value `root`
    for the file `/tmp/a.a`.

        propery_value { 'File[/tmp/a.a]owner':
          value => 'root'
        }

  DESC
end
