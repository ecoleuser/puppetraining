#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
# This is a hiera data adapter that allows for version specific yaml files. Here is an example on how to use it in your hiera.yaml:
#
#       - name: "Version data for all version 12.2 versions."
#         data_hash: 'easy_type::versioned_data'
#         path: version_12.2.yaml
#         options:
#           variable: ibm_profile::mq_machine::version
#           specification:
#             - '>= 12.2'
#             - '< 12.3'
#
# This yaml file will loaded whith for example these versions:
#  - 12.2
#  - 12.2.1
#  - 12.2.1.1.1.1
#  - etc
#
# With the parameter 'variable' you specify what variable is used to specifiy the version you want to use to differentiate
# between multiple yaml files. 
#
# The specifications value can be a single string or an array of strings specificying the specification. See [here](https://guides.rubygems.org/patterns/#declaring-dependencies)
# for a full explanation
#
require 'yaml'
Puppet::Functions.create_function('easy_type::versioned_data') do

  dispatch :versioned_data do
    param 'Hash', :options
    param 'Any', :context
    # param 'Puppet::LookupContext', :context
  end
  
  argument_mismatch :missing_path do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end
    
  def versioned_data(options, context)
    #
    # First fetch all options
    #
    path = options['path']
    variable = options['variable']
    key = options['key']
    specification = options['specification']
    #
    # Check all parameters
    #
    fail "Version specification must be specified." unless specification
    fail "Specify either 'key' or 'variable' not both." if key && variable
    fail "Specify either 'key' or 'variable'." if !key && !variable
    if variable
      scope = closure_scope
      return context.not_found unless scope.include?(variable)
      value = scope[variable]
    else
      fail 'Not yet implemented'
      value = lookup(key)
      return context.not_found if value.empty?
    end
    #
    # Variable exists. No do comparisson
    #    
    return context.not_found unless Gem::Dependency.new('', specification).match?('', value)
    #
    # The specified version matches to the specification. Fetch the data
    #
    context.cached_file_data(path) do |content|
      begin
        #
        # Try to use the safest possible way to load the yaml. This depends on 
        # the used ruby versions.
        #
        if defined?(YAML.safe_load)
          data = YAML.safe_load(content, [Symbol], [], false, path)
        else
          data = YAML.load(content)
        end
    
        if data.is_a?(Hash)
          Puppet::Pops::Lookup::HieraConfig.symkeys_to_string(data)
        else
          msg = _("%{path}: file does not contain a valid yaml hash" % { path: path })
          raise Puppet::DataBinding::LookupError, msg if Puppet[:strict] == :error && data != false
          Puppet.warning(msg)
          {}
        end
      rescue Puppet::Util::Yaml::YamlLoadError => ex
        # YamlLoadErrors include the absolute path to the file, so no need to add that
        raise Puppet::DataBinding::LookupError, _("Unable to parse %{message}") % { message: ex.message }
      end
    end
  end

  def lookup(value)
    call_function('lookup', value, nil, 'first', nil)
  end


  def missing_path(options, context)
    "one of 'path', 'paths' 'glob', 'globs' or 'mapped_paths' must be declared in hiera.yaml when using this data_hash function"
  end
end