#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type'

Puppet::Type.type(:em_entitlement).provide(:simple) do
  include EasyType::Provider

  desc 'Manage Enterprise Modules entitlements for indivudual nodes '

  mk_resource_methods
end
