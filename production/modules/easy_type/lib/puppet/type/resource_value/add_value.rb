#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newproperty(:add_value) do
  include EasyType

  munge do |value|
    [value] unless value.is_a?(::Array)
  end

  desc <<-DESC
    The value you want to add to the array resource property.

    Here is an example on how to use this:

        ora_user { 'USER@test':
          ensure               => 'present',
          default_tablespace   => 'USERS',
          grants               => ['ALTER SYSTEM', 'ALTER DATABASE'],
        }

    Somewhere else in your manifest, you want to add an extra grant. You can do this like this:

        resource_value{'Ora_user[USER@test]grants/1':
          add_value => 'SELECT ANY DICTIONARY',
        }

    The `add_value` property also supports an array value:

        resource_value{'Ora_user[USER@test]grants/more_grants':
          add_value => ['ALTER SESSION', 'CONNECT'],
        }

  DESC
end
