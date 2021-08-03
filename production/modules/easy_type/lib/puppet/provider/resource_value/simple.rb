#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type'

Puppet::Type.type(:resource_value).provide(:simple) do
  include EasyType::Provider

  desc 'Manage individual properties as a full resource'

  mk_resource_methods
end
