#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
# encoding: UTF-8

require 'yaml'
require 'deep_merge'

# docs
module EasyType
  #
  # module to include in a yaml based type
  #
  module YamlType
    # @private
    def self.included(parent)
      parent.include(EasyType)
      parent.extend(ClassMethods)
    end

    PUPPET_META_ATTRIBUTES ||= [:name,
                              :alias,
                              :audit,
                              :before,
                              :loglevel,
                              :noop,
                              :notify,
                              :require,
                              :schedule,
                              :stage,
                              :subscribe,
                              :tag,
                              :provider].freeze

    def add
      self.class.get_raw_resources
      on_apply
    end

    def remove
      self.class.get_raw_resources
      self.class.configuration.delete(name)
      write_yaml
      secure_yaml
    end

    def on_create
      on_apply
    end

    def on_modify
      on_apply
    end

    def on_apply
      merge_configuration
      #
      # Let all properties do there own on_modify stuff before we save it.
      # This is a bit of a hack, because easy_type will call the on_modify
      # method anyway.....but after the data has already been saved.
      #
      properties.each do |property|
        if property.respond_to?(:on_modify)
          property.on_modify
        elsif property.respond_to?('on_apply')
          property.on_apply
        end
      end
      write_yaml
      secure_yaml
      nil
    end

    def current_config
      self.class.configuration.fetch(name) { {} }
    end

    private

    def merge_configuration
      # Always write defaults because we cannot support more then one setting
      return unless self.class.configuration # When no license is found, this is nil
      self.class.configuration.deep_merge!(name.to_s => settings_for_resource)
    end

    def settings_for_resource
      settings = to_hash.reject { |key, _value| PUPPET_META_ATTRIBUTES.include?(key) || !parameters[key].is_a?(EasyType::YamlProperty) }
      stringify_keys(settings)
    end

    def write_yaml
      open(self.class.config_file, 'w+') { |f| YAML.dump(fix_booleans(self.class.configuration), f) }
    end

    def fix_booleans(hash)
      resource_api_available? do
        properties.each do | property|
          hash.keys.each do |resource|
            property_name = property.name.to_s
            next if property_name == 'ensure'
            hash[resource][property_name] = (hash[resource][property_name].to_s == 'true') if property.class.is_a_boolean_kind?
          end
        end
      end
      hash
    end

    def secure_yaml
      FileUtils.chmod(0o600, [self.class.config_file])
    end

    def stringify_keys(hash)
      result = {}
      hash.each do |key, value|
        result[key.to_s] = if value.is_a?(Symbol)
                             value.to_s
                           else
                             value
                           end
      end
      result
    end

    #
    # Class methods for yaml based types
    #
    module ClassMethods
      def get_raw_resources
        Puppet.debug "YAML index #{name} "
        resources_from_yaml
      end

      def configuration
        @configuration
      end

      def resources_from_yaml
        Puppet.debug 'read_from_yaml '
        @configuration = read_from_yaml
        normalize(@configuration)
      end

      def config_file(file = nil)
        if file
          @config_file = file
        else
          Pathname.new(@config_file).expand_path
        end
      end

      def read_from_yaml
        if File.exist?(config_file)
          # The safe version introduced all sorts of issues and
          # the original one doesn't introduce security issues in
          # this contect
          # rubocop: disable Security/YAMLLoad
          data = open(config_file) { |f| YAML.load(f) }
          #
          # If the file is empty or conatains no valid content, data is either nil or false
          # We need to handle that here.
          #
          (data.nil? || data == false) ? {} : data
          # rubocop: enable Security/YAMLLoad
        else
          {}
        end
      end

      private

      def normalize(content)
        content = {} if content.nil?
        normalized_content = []
        content.each do |key, value|
          value[:name] = key
          normalized_content << with_hashified_keys(value)
        end
        normalized_content
      end

      def with_hashified_keys(hash)
        result = {}
        hash.each do |key, value|
          result[key.to_sym] = value
        end
        result
      end
    end
  end
end
