#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:ensure_value) do
    include EasyType
  
    desc <<-DESC
      The value to use for ensuring presence.
    DESC
  
    defaultto 'present'
  end
  