#
# See the file "LICENSE" for the full license governing this code.
#
# Write some data to the catalog in a secure way.
#
# frozen_string_literal: true
require 'json'
$LOAD_PATH << (Pathname.new(__FILE__).dirname.parent.parent.parent.expand_path)
require 'easy_type/encryption'

Puppet::Functions.create_function('easy_type::write_secured_data') do
  include EasyType::Encryption

  dispatch :write_secured_data do
    param 'String[1]', :key
    param 'Any', :data
  end

  def write_secured_data(key, data)
    secured_data = encrypt(data.to_json)
    puppet_code = <<-PUPPET_CODE
      em_data { '#{key}':
        data => '#{secured_data}',
      }
    PUPPET_CODE
    call_function('easy_type::evaluate_puppet', puppet_code)
  end

end
