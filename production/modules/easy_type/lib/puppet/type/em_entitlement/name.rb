#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:name) do
  include EasyType

  desc <<-DESC
  The full name of the node and module to be entitled.
  DESC

  isnamevar

  to_translate_to_resource do |raw_resource|
    license_id      = raw_resource[:license_id]
    entitled_module = raw_resource[:entitled_module]
    puppet_server   = raw_resource[:puppet_server]
    node_name       = raw_resource[:node_name]
    "#{license_id}/#{entitled_module}@#{node_name}->#{puppet_server}"
  end
end
