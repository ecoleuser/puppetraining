#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'puppet/file_serving'
require 'puppet/file_serving/content'
require 'csv'

# rubocop: disable Metrics/AbcSize

module EasyType
  #
  # Contains a set of helpe methods and classed that can be used throughtout
  # EasyType
  module Helpers
    # @private
    def self.included(parent)
      parent.extend(Helpers)
    end
    #
    # TODO: Add documentation
    #
    class InstancesResults < Hash
      #
      # @param [Symbol] column_name the name of the column to extract from the
      # Hash
      # @raise [Puppet::Error] when the column name is not used in the Hash
      # @return content of the specified key in the Hash
      #
      def column_data(column_name)
        fetch(column_name) do
          raise "Column #{column_name} not found in results. Results contain #{keys.join(',')}"
        end
      end
    end

    #
    # Convert a comma separated string into an Array of Hashes
    #
    # @param [String] csv_data comma separated string
    # @param [Array] headers of [Symbols] specifying the key's of the Hash
    # @param [Hash] options parsing options. You can specify all options of
    #               CSV.parse here
    # @return [Array] of [InstancesResults] a special Hash
    #
    HEADER_LINE_REGEX ||= /\A[-\s]+\z/

    def convert_csv_data_to_hash(csv_data, headers = [], options = {})
      options = check_options(options)
      default_options = {
        :header_converters => lambda { |f| f ? f.strip : nil }
      }
      default_options[:headers] = if headers != []
                                    headers
                                  else
                                    true
                                  end
      options = default_options.merge(options)
      skip_lines = options.delete(:skip_lines) { HEADER_LINE_REGEX }
      #
      # This code replace all quote character to a string. After the
      # CSV parser, these values are replaced back again. This code is required
      # to allow for quotes in the data
      #
      csv_data.gsub!('"""', '|&quote|') # Translate quotes
      data = []
      ::CSV.parse(csv_data, **options) do |row|
        unless row_contains_skip_line(row, skip_lines)
          row_data = row.to_a.collect { |r| [r[0], r[1].nil? ? nil : r[1].gsub('|&quote|', '"')] }
          data << InstancesResults[row_data]
        end
      end
      data
    end

    #
    # Camelize a string. This code is "borrowed" from RAILS. Credits and copyrights
    # to them.
    #
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(%r{\/(.?)}) { "::#{Regexp.last_match(1).upcase}" }.\
          gsub(/(?:^|_)(.)/) { Regexp.last_match(1).upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end

    ##
    #
    # This allows you to use a puppet syntax for a file and return it's content.
    #
    # @example
    #  get_puppet_file 'puppet:///modules/my_module_name/create_tablespace.sql.erb'
    #
    # @param [String] url this is the name of the template to be used.
    #
    # @raise [ArgumentError] when the file doesn't exist
    # @return [Any] Content of the file
    #
    def get_puppet_file(url)
      # Somehow there is no consistent way to determine what terminus to user. So we switch to a
      # trial and error method. First we start withe the default. And if it doesn't work, we try the
      # other ones
      status = load_file_with_any_terminus(url)
      raise ArgumentError, "Previous error(s) resulted in Puppet being unable to retrieve information from environment #{Puppet['environment']} source(s) #{url}'\nMost probable cause is file not found." unless status
      status.content
    end

    private

    # rubocop:disable HandleExceptions
    def load_file_with_any_terminus(name)
      termini_to_try = [:file_server, :rest]
      termini_to_try.each do |terminus|
        with_terminus(terminus) do
          begin
            content = Puppet::FileServing::Content.indirection.find(name)
          rescue SocketError, Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTDOWN, Errno::EHOSTUNREACH, Errno::ETIMEDOUT, Puppet::HTTP::RouteError
            # rescue any network error
          end
          return content if content
        end
      end
      nil
    end
    # rubocop:enable HandleExceptions

    def row_contains_skip_line(row, skip_lines)
      if row.respond_to?(:fields)
        !skip_lines.match(row.fields.join).nil?
      else
        false
      end
    end

    def check_options(options)
      deprecated_option(options, :column_delimeter, :col_sep)
      deprecated_option(options, :line_delimeter, :row_sep)
      options
    end

    def with_terminus(terminus)
      old_terminus = Puppet[:default_file_terminus]
      Puppet[:default_file_terminus] = terminus
      value = yield
      Puppet[:default_file_terminus] = old_terminus
      value
    end

    def deprecated_option(options, old_id, new_id)
      old_value = options.delete(old_id)
      return unless old_value
      Puppet.deprecation_warning("#{old_id} deprecated. Please use #{new_id}")
      options[new_id] = old_value
    end
  end
end
# rubocop: enable Metrics/AbcSize
