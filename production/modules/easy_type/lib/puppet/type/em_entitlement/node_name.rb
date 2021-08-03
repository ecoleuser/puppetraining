#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:node_name) do
  include EasyType

  desc <<-DESC
  The FQDN of the node you want to entitle the use of ths specfied Puppet module for.
  DESC

  isnamevar

  defaultto {
    Facter.value(:fqdn)
  }

end
