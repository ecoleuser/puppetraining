#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type'

# TODO: Add documentation
Puppet::Type.newtype(:em_entitlement) do
  include EasyType

  def self.module_name
    'easy_type'
  end

  REGISTERED_NODES_FILE = "#{Puppet[:confdir]}/em_license/entitlements.yml".freeze

  desc <<-DESC
  Using this Puppet type, you can manage the nodes entitled to use a specific module.

  Here is an example on how to use this:

      em_entitlement { 'license_id/my_module@mynode2.domain.nl->puppet.server.com':
        ensure => 'present',
      }

  The way to read this is:

  The license provided by Enterprise Modules with license_id, allows you to use the module `my_module` on a number of named nodes. 
  This puppet declaration enables node `puppet.server.com` connected to puppet server `puppet.server.com` one of these entitlements.

  You can also use the variant without a specified pupet server. The syntax is then:

      em_entitlement { 'licenseid/module@mynode2.domain.nl':
        ensure => 'present',
      }

  It will then use the current puppet server as the default.

  DESC

  to_get_raw_resources do 
    Puppet.debug "Fetching entitled nodes..."
    resources_from_yaml
  end

  def on_create
    on_apply
  end

  def on_modify
    on_apply
  end

  def on_destroy
    self.class.configuration[license_id][entitled_module][puppet_server].delete(node_name)
    write_yaml
    secure_yaml
  end

  def on_apply
    merge_configuration
    write_yaml
    secure_yaml
    nil
  end
  
  #
  # lic_id/ora_config@node->puppet_server
  #
  map_titles_to_attributes([
    /((.*)\/(.*)@(.*)->(.*))/, [:name, :license_id, :entitled_module, :node_name, :puppet_server],
    /((.*)\/(.*))/           , [:name, :license_id, :entitled_module]
    ])

  ensurable

  parameter :name
  parameter :license_id
  parameter :entitled_module
  parameter :puppet_server
  parameter :node_name

  def self.configuration
    @configuration
  end

  def self.resources_from_yaml
    Puppet.debug 'read_from_yaml'
    @configuration = read_from_yaml
    normalize(@configuration)
  end

  def self.read_from_yaml
    if File.exist?(REGISTERED_NODES_FILE)
      # The safe version introduced all sorts of issues and
      # the original one doesn't introduce security issues in
      # this contect
      # rubocop: disable Security/YAMLLoad
      open(REGISTERED_NODES_FILE) { |f| YAML.load(f) }
      # rubocop: enable Security/YAMLLoad
    else
      {}
    end
  end

  def self.normalize(content)
    content = {} if content.nil?
    normalized_content = []
    begin
      content.each do |license_id, hash|
        hash.each do | entitled_module, hash| 
          hash.each do |puppet_server, nodes|
            nodes.each do |node|
              normalized_content << {:license_id => license_id, :entitled_module => entitled_module, :puppet_server => puppet_server, :node_name => node }
            end
          end
        end
      end
    rescue 
      fail "File #{REGISTERED_NODES_FILE} contains invalid syntax."
    end
    normalized_content
  end

  def current_config
    self.class.configuration.fetch(name) { {} }
  end

  private

  def merge_configuration
    self.class.configuration[license_id] ||= {}
    self.class.configuration[license_id][entitled_module] ||= {}
    self.class.configuration[license_id][entitled_module][puppet_server] ||= []
    self.class.configuration[license_id][entitled_module][puppet_server] << node_name
  end

  def write_yaml
    File.open(REGISTERED_NODES_FILE, 'w') do |out|
      out << self.class.configuration.to_yaml
    end
  end

  def secure_yaml
    FileUtils.chmod(0o600, [REGISTERED_NODES_FILE])
  end

end
