#
# See the file "LICENSE" for the full license governing this code.
#
#
# Validate if the specified product_version and doc_version is an
# existing combination. If not give a readable error message that shows
# available versions
#
Puppet::Functions.create_function('easy_type::validate_versions') do
  dispatch :validate_versions do
    param 'String[1]',          :module_name
    param "Enum['cis','stig']", :type
    param 'String[1]',          :product_version
    param 'String[1]',          :doc_version
  end

  def validate_versions(module_name, type, product_version, doc_version)
    valid_doc_versions = valid_combinations(module_name, type)[product_version]
    raise Puppet::Error.new("product_version '#{product_version}' is not known and/or supported.\n Valid versions are #{valid_product_versions(module_name, type)}") if valid_doc_versions.nil?
    raise Puppet::Error.new("doc_version '#{doc_version}' is not known and/or supported for  product_version '#{product_version}'.\n Valid versions for product_version '#{product_version}' are #{valid_doc_versions.join(',')}") unless valid_doc_versions.include?(doc_version)
    true
  end

  def valid_product_versions(module_name, type)
    valid_combinations(module_name, type).keys.join(',')
  end

  def valid_combinations(module_name, type)
    @valid_combinations ||= call_function('lookup', "#{module_name}::#{type}::valid_combinations", data_type('Hash[String[1], Array[String[1]]]'), 'first', nil)
  end

  def data_type(string)
    parser = Puppet::Pops::Types::TypeParser.singleton
    parser.parse(string)
  end

end