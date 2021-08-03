#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
# This function takes care of putting all the license files in the correct
# location so the EM license checks work with the current settings of
# the entitlements.yml and the current licenses.
#
require 'tempfile'
require 'yaml'
$LOAD_PATH << (Pathname.new(__FILE__).dirname.parent.parent.parent.expand_path)
require 'easy_type'
require 'easy_type/node_group_data'

Puppet::Functions.create_function('easy_type::em_prep') do
  # @param targets A pattern or array of patterns identifying a set of targets.
  # @param options Options hash.
  # @option options [Array] _required_modules An array of modules to sync to the target.
  # @example Prepare targets by name.
  #   em_prep('target1,target2')
  dispatch :em_prep do
    param 'Boltlib::TargetSpec', :targets
    optional_param 'Hash[String, Data]', :options
  end

  ENTITLEMENTS_FILE       ||= '/etc/puppetlabs/puppet/em_license/entitlements.yml'.freeze
  BOLT_ENTITLEMENTS_FILE  ||= '/tmp/entitlements.yml'.freeze
  BOLT_NODE_GROUP_CACHE   ||= '/tmp/node_groups.cache'.freeze
  BOLT_RUN_INFO           ||= '/tmp/run_info.yaml'.freeze

  def executor
    @executor ||= Puppet.lookup(:bolt_executor)
  end

  def inventory
    @inventory ||= Puppet.lookup(:bolt_inventory)
  end

  def em_prep(target_spec, options = {})
    unless Puppet[:tasks]
      raise Puppet::ParseErrorWithIssue
        .from_issue_and_stack(Bolt::PAL::Issues::PLAN_OPERATION_NOT_SUPPORTED_WHEN_COMPILING, action: 'apply_prep')
    end

    targets = inventory.get_targets(target_spec)
    #
    # Register the current puppetserver in a yaml file and put it on the agent
    #
    bolt_run_data = { 
      :puppet_server => Facter.value(:fqdn)
    }
    run_info_file = Tempfile.open { |f| YAML.dump(bolt_run_data, f) }
    ObjectSpace.undefine_finalizer(run_info_file)
    executor.upload_file(targets, run_info_file.path, BOLT_RUN_INFO, 
      :description => 'Uploading Enterprise Modules run-time information...')
    # Update the entitlements file to the agent
    #
    executor.upload_file(targets, ENTITLEMENTS_FILE, BOLT_ENTITLEMENTS_FILE, 
      :description => 'Uploading Enterprise Modules entitlements information...') if File.exists?(ENTITLEMENTS_FILE)

    #
    # Create a local node group cache
    #
    nodegroup_mgr = EasyType::NodeGroupData.new('/tmp/node_groups.cache')
    nodegroup_mgr.load_from_server
    nodegroup_mgr.save_node_group_cache
    executor.upload_file(targets, BOLT_NODE_GROUP_CACHE, BOLT_NODE_GROUP_CACHE, 
      :description => 'Uploading Enterprise Modules node groups information...') 
  end
end
  
  