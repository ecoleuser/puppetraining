#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:property_name) do
  desc <<-DESC
    The property of the resource you want to manage. It is the part after the `]`. In the next example:

        propery_value { 'File[/tmp/a.a]owner':
          ...
        }

    `owner` is the property name.

  DESC

  isnamevar
end
