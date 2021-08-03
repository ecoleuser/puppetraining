#
# See the file "LICENSE" for the full license governing this code.
#
# A function to be used by bolt plans to write some data to a specfied 
# file in the yaml formar
#
require 'yaml'
Puppet::Functions.create_function('easy_type::write_yaml') do

  dispatch :write_yaml do
    param       'String[1]', :file_name
    param       'Hash',      :data
  end

  def write_yaml(file_name, data)
    File.open(file_name, "w") { |file| file.write(data.to_yaml) }
  end
end
