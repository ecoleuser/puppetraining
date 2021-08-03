#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:puppet_server) do
  include EasyType

  desc <<-DESC
  The full name of the puppet server that provides the catalog to the node you want to use the specified Puppet module on.
  DESC

  isnamevar

  defaultto {
      base_server      = Puppet.settings[:server]
      server_addresses = Resolv.getaddresses(base_server)
      server_addresses.collect { |ip| Resolv.getnames(ip) }.flatten.first
  }

end
