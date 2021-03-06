#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

module EasyType
  # docs
  module PathHelpers
    # @private
    def self.included(parent)
      parent.extend(PathHelpers)
    end

    #
    # Search the modulepath for where easy_type's template's are stored
    #
    def template_path(template)
      modulepath.each do |path|
        return path if File.exist?("#{path}/easy_type/templates/#{template}")
      end
      raise "Template #{template} not found in modulepath #{modulepath}"
    end

    #
    # return the directory where the types reside
    #
    def type_directory
      Pathname.new(puppet_lib) + 'type'
    end

    #
    # Give the full path name of a ruby file containing the type definition
    #
    def type_path
      type_directory + "#{@name}.rb"
    end

    #
    # Return the name of the provider directory
    #
    def provider_directory
      Pathname.new(puppet_lib) + 'provider' + @name
    end

    #
    # Return the full path name of a ruby file describing the provider
    #
    def provider_path
      provider_directory + "#{@provider}.rb"
    end

    #
    # Return the directory name where the shared type definitions reside
    #
    def type_shared_directory
      Pathname.new(puppet_lib) + 'type' + 'shared'
    end

    #
    # Give the full path name of a ruby file describing the name parameter
    #
    def name_attribute_path
      type_attribute_directory + "#{@namevar}.rb"
    end

    #
    # Give the full path name of a ruby file describing the parameter
    #
    def attribute_path
      type_attribute_directory + "#{@attribute_name}.rb"
    end

    #
    # Give the full path name of a ruby file describing the shared property
    #
    def shared_attribute_path
      type_shared_directory + "#{@attribute_name}.rb"
    end

    #
    # Give the directory name where the type definitions reside
    #
    def type_attribute_directory
      Pathname.new(puppet_lib) + 'type' + @name
    end

    #
    # Return the puppet library path of the current custom type
    #
    def puppet_lib
      File.expand_path('./lib/puppet')
    end

    #
    # Returns a true if the expected puppet library path exists
    #
    def puppet_lib?
      File.exist?(puppet_lib)
    end

    #
    # Returns the system wide module path
    #
    def modulepath
      env = Puppet.lookup(:current_environment)
      @modulepath ||= if env.modulepath == []
                        ['./spec/fixtures/modules']
                      else
                        env.modulepath
                      end
    end

    #
    # Create a directory and notify user of it's creation
    #
    def create_directory(path)
      return if File.exist?(path)
      FileUtils.mkdir_p path
      Puppet.notice "Created directory #{path}"
    end

    #
    # Write the content to a file. If the file exists, it will not be overwritten
    # unless the --force option is set. The user will be notified of the creation
    # of the file
    #
    def write_file(path, content)
      file_exists = File.exist?(path)
      raise "File #{path} already exists. Not overwritten. Use --force to overwrite" if file_exists && !@force
      save_file(path, content)
      message = file_exists ? "File #{path} overwriten with new content" : "File #{path} created"
      Puppet.notice message
    end

    #
    # Create a source file based on a ERB template
    #
    def create_source(name, destination)
      template = File.read("#{template_path(name)}/easy_type/templates/#{name}")
      content = ERB.new(template, nil, '-').result(binding)
      write_file(destination, content)
    rescue SyntaxError
      raise "Error in erb template #{name}"
    end

    #
    # Save some content to a file
    #
    def save_file(path, content)
      File.open(path, 'w') do |f|
        f.write content
      end
    end
  end
end
