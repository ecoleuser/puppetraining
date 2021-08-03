#
# See the file "LICENSE" for the full license governing this code.
#
# Write some data to the catalog
#
# frozen_string_literal: true
require 'json'

Puppet::Functions.create_function('easy_type::write_data') do
  dispatch :write_data do
    param 'String[1]', :key
    param 'Any', :data

  end

  def write_data(key, data)
    puppet_code = <<-PUPPET_CODE
      em_data { '#{key}':
        data => '#{data.to_json}',
      }
    PUPPET_CODE
    call_function('easy_type::evaluate_puppet', puppet_code)
  end

end
