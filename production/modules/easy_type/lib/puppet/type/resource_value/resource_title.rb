#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:resource_title) do
  desc <<-DESC
    The title of the resource you want to manage. It is the part between the `[` and the `]`. In the next example:

        propery_value { 'File[/tmp/a.a]owner':
          ...
        }

    `/tmp/a.a` is the type name.

  DESC

  isnamevar
end
