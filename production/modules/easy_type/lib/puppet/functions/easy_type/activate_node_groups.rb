#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'pathname'
$LOAD_PATH << (Pathname.new(__FILE__).dirname.parent.parent.parent.expand_path)
require 'easy_type'
require 'easy_type/node_group_data'

Puppet::Functions.create_function('easy_type::activate_node_groups') do
  dispatch :activate_node_groups do
  end

  def activate_node_groups
    if classifier_running?
      Puppet.debug "Classifier running. Using classifier data."
      data = EasyType::NodeGroupData.new('/var/enterprisemodules/node_groups.cache').load_from_server
    else
      data = {}
      Puppet.debug "Skipping interrogating EM nodegroups because classifier not running."
    end
    call_function('easy_type::write_secured_data', 'node_group_data', data)
  end

  def classifier_running?
    return false unless closure_scope['kernel'] == 'Linux'
    Puppet::Util::Execution.execute('netstat -lnp | grep 4433', :failonfail => false) != ''
  end
end
