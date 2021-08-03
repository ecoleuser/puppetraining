#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
# encoding: UTF-8

require 'easy_type/helpers'

module EasyType
  #
  # Contains a template helper method.
  #
  module Template
    include EasyType::Helpers

    # @private
    def self.included(parent)
      parent.extend(Template)
    end

    ##
    #
    # This allows you to use an erb file. Just like in the normal Puppet classes. The file is searched
    # in the template directory on the same level as the ruby library path. For most puppet classes
    # this is eqal to the normal template path of a module
    #
    # @example
    #  template 'puppet:///modules/my_module_name/create_tablespace.sql.erb', binding
    #
    # @param [String] name this is the name of the template to be used.
    # @param [Binding] context this is the binding to be used in the template
    #
    # @raise [ArgumentError] when the file doesn't exist
    # @return [String] interpreted ERB template
    #
    def template(template_name, context)
      if template_name =~ /puppet:/
        puppet_template(template_name, context)
      else
        local_template(template_name, context)
      end
    end

    def local_template(template_name, context)
      segments = template_name.split('/')
      fail "template name #{template_name} invalid. Template name should include module directory" \
        if segments.size < 2
      module_name = segments.shift
      core_template_name = segments.pop
      folder_name = segments.join('/')
      content = File.read("#{template_base_path(module_name)}/provider/#{folder_name}/templates/#{core_template_name}")
      ERB.new(content, nil, '-').result(context)
    rescue Errno::ENOENT
      raise ArgumentError, "Could not find template '#{template_name}'. "
    end

    def puppet_template(template_name, context)
      ERB.new(get_puppet_file(template_name), nil, '-').result(context)
    end

    private

    #
    # All of the templates are stored in the provider path at a subdirectory
    # templates.
    #
    def template_base_path(module_name)
      current_path = Pathname.new(__FILE__).dirname
      if on_master?(current_path) || in_bolt?(current_path)
        current_path.parent.parent.parent + module_name + 'lib' + 'puppet'
      else
        current_path.parent + 'puppet'
      end
    end

    #
    # We decide if we are on master if the specified path contains the string
    # `module`. If we are running on an agent, all ruby code is placed in the
    # cache directory.
    #
    def on_master?(path)
      path.to_s =~ %r{/modules/}
    end

    #
    # We decide if we are running in Bolt if the current path includes the tems 'spool' and
    # 'temp_task'. This is validated when running a task through Puppet Enterprise. We need to
    # check if this is the best way to do this.
    # TODO: Find the best way to determine if we are running in bolt and 
    #
    def in_bolt?(path)
      path.to_s =~ %r{\/tmp\/\w+-\w+-\w+-\w+-\w+|.*\/spool\/.*\/temp_task.*}
    end
  end
end
