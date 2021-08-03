#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'puppet/face'
require 'easy_type/node_group_data'

Puppet::Face.define(:emlicense, '0.0.1') do
  action(:groups) do
    summary 'Show all node groups'

    description <<-DESC
      Inspect EM node groups
    DESC

    when_invoked do |*_args|
      ng_manager = EasyType::NodeGroupData.new(nil)
      puts ng_manager.load_from_server.inspect
      nil
    end
  end
end
