# frozen_string_literal: true

# docs
class Compressor
  attr_reader :type_name

  def initialize(type_name)
    @type_name = type_name
  end

  def type_file
    "lib/puppet/type/#{@type_name}.rb"
  end

  def type_path
    "lib/puppet/type/#{@type_name}/"
  end

  def shared_path
    'lib/puppet/type/shared/'
  end

  def type_text
    @type_text ||= File.open(type_file, 'rb', &:read)
  end

  def shared_name(property)
    "#{shared_path}#{property}.rb"
  end

  def specific_name(property)
    "#{type_path}#{property}.rb"
  end

  def shared_property?(property)
    File.exist?(shared_name(property))
  end

  def specific_property?(property)
    File.exist?(specific_name(property))
  end

  def shared_property(property)
    File.open(shared_name(property), 'rb', &:read)
  end

  def specific_property(property)
    File.read(specific_name(property))
  end

  def content_for(property)
    content = if specific_property?(property)
                specific_property(property)
              elsif shared_property(property)
                shared_property(property)
              else
                raise ArgumentError, "property #{property} not found"
              end
    content
  end

  def remove_comments
    type_text.gsub!(/#(?!\{.*\}).*/, '')
  end

  def remove_newlines
    @type_text.gsub!("\n\n", "\n")
    # @type_text.gsub!(/(?<![,+-\{])\n/,";")
  end

  def include_properties
    properties = type_text.scan(/(?:parameter|property|incude_file)\s+:(\w+)/)
    properties.each do |property|
      property = property.first
      STDERR.puts "processing #{type_name}:#{property}..."
      regexp = /(?:property|parameter|incude_file)\s+:#{property}\s*$/
      @type_text.gsub!(regexp, content_for(property))
    end
  end

  def compress
    remove_comments
    include_properties
    # remove_newlines
    @type_text
  end
end
