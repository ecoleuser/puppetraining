#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:unique) do
  desc <<-DESC
  The unique maker of the resource you want to manage.

      When using the `add_value` or `remove_value` use cases, you might want to
      create multiple `resource_value` definitions on the same basic resource.
      Because Puppet mandates unique titles, we have added the possibility to add
      a unique maker to the end of the title. It has no other functional use than making
      the title unique. It is the last part of the title.

          propery_array_value { 'Host[www.example.com]host_aliases/1':
            ...
          }

      In this example the number 1 is the number that makes the title unique. But
      it doesn't have to be a number. It can also be a string.

          propery_array_value { 'Host[www.example.com]host_aliases/add_extra':
          ...
          }

  DESC

  isnamevar
end
