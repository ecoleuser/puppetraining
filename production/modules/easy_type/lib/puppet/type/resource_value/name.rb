#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:name) do
  desc <<-DESC
    The full qualified name of the resource value you want to set. The full qualified name
    contains:

    - The type name (e.g. Host)
    - The resource title (e.g. 'myhost.example.com')
    - The property name (e.g. 'host_aliases')

    When you want to work with array values, you can use the serial number

    - The serial number (e.g. 1,2...etc)

    Here is an example of a full qualified name:

        propery_value { 'Host[myhost.example.com]host_aliases/1':
          ...
        }
  DESC

  isnamevar
end
