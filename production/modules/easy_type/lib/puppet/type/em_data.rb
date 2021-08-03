#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type'

# TODO: Add documentation
Puppet::Type.newtype(:em_data) do
  include EasyType

  def self.module_name
    'easy_type'
  end


  desc <<-DESC
  Type to store data in de catalog. 
  DESC

  to_get_raw_resources do
    []
  end

  parameter :name
  parameter :data

end
