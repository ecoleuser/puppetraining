#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:resource_type) do
  desc <<-DESC
    The name of the type you want to manage. It is the first part of the title. In the next example:

        propery_value { 'File[/tmp/a.a]owner':
          ...
        }

    `File` is the type name.

  DESC

  isnamevar
end
