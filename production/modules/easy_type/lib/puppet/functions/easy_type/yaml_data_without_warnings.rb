#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
# This is a hiera lookup backend that you can use to fetch data based on locale puppet
# variables without hiera giving you a warning when the variable doesn't exist. It can only 
# be used in the context of a module at this point in time.
#
# You have to specify the `file_name` option in the `hiera.yaml`. Puppet variables
# can be used in this entry just like in regular puppet interpollation. Here is an example:
#
# ```yaml
#    - name: "Control data"
#    data_hash:  easy_type::yaml_data_without_warnings
#    options:
#    file_name: "benchmarks/cis/${db_version}/${doc_version}/control_data.yaml"
# ```
#
require 'yaml'
Puppet::Functions.create_function('easy_type::yaml_data_without_warnings') do

  dispatch :yaml_data_without_warnings do
    param 'Hash', :options
    param 'Any', :context
  end
  
  argument_mismatch :missing_path do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end
    
  def yaml_data_without_warnings(options, context)
    #
    # Check if we are running i the module context. For now that is
    # the only context we support in this lookup
    #
    if context.module_name.to_s == ''
      context.explain { "Running outside of module scope. skpping lookup." } 
      return context.not_found
    end
    #
    # Now process the options specified
    #
    file_name = options['file_name']
    raise Puppet::Error.new("the 'easy_type::yaml_data_without_warnings' backend needs a file_name option field") if file_name.nil?
    #
    # All set let's get going.
    #
    context.explain { "File specified in hiera.yaml is '#{file_name}'" }
    #
    # Now check all specified variables and skip the lookup if one of the variables is not set
    # or when it is an empty array.
    #
    variable_values = {}
    variable_names = file_name.scan(/\$\{(.+?)\}/)&.flatten
    variable_names.each do |variable_name| 
      variable_values[variable_name] = fetch_variable(context, variable_name)
      if variable_values[variable_name].nil? || (variable_values[variable_name].is_a?(Array) && variable_values[variable_name].empty?)
        context.explain {"Variable '#{variable_name}' not set, or empty; skipping this lookup." }
        return context.not_found
      end
    end
    file_names = []
    all_combinations(variable_values.values).each do | combination|
      result = file_name.dup
      variable_names.each_with_index {| name, index| result.gsub!("${#{name}}", combination[index])}
      file_names << result
    end
    #
    # All variables are valid now get one or more *real* file names
    #
    data = {}
    file_names.each do | file_name|
      context.explain { "File name after variable substitution is '#{file_name}'" }
      data_dir = File.expand_path(File.dirname(__FILE__) + "/../../../../../#{context.module_name}/data")
  
      path = "#{data_dir}/#{file_name}"
      if !File.exists?(path)
        context.explain { "File '#{path}' not found skipping this lookup." }
        return context.not_found
      end
      context.cached_file_data(path) do |content|
        begin
          #
          # Try to use the safest possible way to load the yaml. This depends on 
          # the used ruby versions.
          #
          if defined?(YAML.safe_load)
            new_data = YAML.safe_load(content, [Symbol], [], false, path)
          else
            new_data = YAML.load(content)
          end
      
          if new_data.is_a?(Hash)
            data.merge!(Puppet::Pops::Lookup::HieraConfig.symkeys_to_string(new_data))
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
    data
  end

  def all_combinations(array)
    result = []
    length = array.map {|e| Array(e).length }.inject(:*)
    array.each_with_index do |value, index|
      if value.is_a?(Array)
        (0...length).each {|i| result[i] ||= []; result[i][index] = value[i % value.length]}
      else
        (0...length).each {|i| result[i] ||= []; result[i][index] = value}
      end
    end
    result
  end
  
  def fetch_variable(context, name)
    return nil unless context.invocation.scope.include?(name)
    context.invocation.scope[name]
  end

  def missing_path(options, context)
    "one of 'path', 'paths' 'glob', 'globs' or 'mapped_paths' must be declared in hiera.yaml when using this data_hash function"
  end
end