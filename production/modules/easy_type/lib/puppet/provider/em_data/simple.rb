#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
require 'easy_type'

Puppet::Type.type(:em_data).provide(:simple) do
  include EasyType::Provider

  desc 'Manage Enterprise Modules catalog data'

  mk_resource_methods

end
