#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
extend Puppet::Util::Warnings

begin
  require 'puppet/resource_api'
  require 'puppet/resource_api/data_type_handling'
rescue LoadError
  Puppet::Util::Warnings.debug_once 'Skipping resource API.'
  # Continue when resource api is not there
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5.0")
  # 
  # Ruby 2.5 and higher warn about __FILE__ in an eval. Since we use 
  # a lot of eval, we get a lot of warnings. We could changes it to 
  # Binding.source_location, but that would break backwards compatibility.
  # For now we override the warning and do nothing when the warning is 
  # issued
  #
  def Warning.warn(warning)
    return if warning =~ /eval may not return location in binding/
    super(warning)
  end
end


def resource_api_available?
  # Needs gradual checks to execute
  return false unless Puppet.const_defined?(:ResourceApi)
  return false unless Puppet::ResourceApi.const_defined?(:DataTypeHandling)

  Puppet::Util::Warnings.debug_once 'Resource API available. executing...'
  yield if block_given?
  true
end

def resource_api_not_available?
  if !resource_api_available?
    Puppet::Util::Warnings.debug_once 'Resource API NOT available. executing...'
    yield if block_given?
    true
  else
    false
  end
end

require 'easy_type/preamble'
require 'easy_type/setup'
require 'easy_type/array_property'
require 'easy_type/daemon'
require 'easy_type/encrypted_property'
require 'easy_type/encrypted_yaml_property'
require 'easy_type/extended_parameter'
require 'easy_type/file_includer'
require 'easy_type/group'
require 'easy_type/helpers'
require 'easy_type/mungers'
require 'easy_type/parameter'
require 'easy_type/provider'
require 'easy_type/resource_task'
require 'easy_type/extract_task'
require 'easy_type/script_builder'
require 'easy_type/syncers'
require 'easy_type/template'
require 'easy_type/type'
require 'easy_type/types'
require 'easy_type/validators'
require 'easy_type/yaml_property'
require 'easy_type/yaml_type'

# @nodoc
module EasyType
  def self.included(parent)
    parent.include( EasyType::Helpers)
    parent.include( EasyType::FileIncluder)
    parent.include( EasyType::Template)
    parent.include( EasyType::Type) if parent.ancestors.include?(Puppet::Type)
    parent.include( EasyType::Parameter) if parent.ancestors.include?(Puppet::Parameter)

    resource_api_available? do
      parent.include( EasyType::ExtendedParameter) if parent.ancestors.include?(Puppet::Parameter)
    end
  end
end
