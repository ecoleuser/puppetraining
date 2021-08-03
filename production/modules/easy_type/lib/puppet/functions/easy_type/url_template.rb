#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

#
# This function can load a template form any puppet url path. It doesn't need
# to be located in the template path, but it does need to be in the files directory
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../..')
require 'easy_type/template'

Puppet::Functions.create_function('easy_type::url_template', Puppet::Functions::InternalFunction) do

  dispatch :url_template do
    scope_param
    param 'String', :template_url
  end

  def url_template(scope, template_url)
    extend EasyType::Template
    scope.to_hash.each do |name, value|
      realname = name.gsub(/[^\w]/, '_')
      instance_variable_set("@#{realname}", value)
    end
    template(template_url, binding)
  end
end
[root@docpup functions]#