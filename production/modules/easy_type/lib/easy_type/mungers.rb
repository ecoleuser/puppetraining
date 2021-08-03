#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

#
#
# Define all common mungers available for all types
#

require 'easy_type'

module EasyType
  #
  # The Integer munger, munges a specified value to an Integer.
  #
  module Mungers
    [Integer, String, Array, Float].each do |klass|
      module_eval(<<-CODE, __FILE__, __LINE__ + 1)
        # @nodoc
        # @private
        module #{klass}
          def unsafe_munge(value)
            if resource_api_available? && self.class.data_type
              super
            else
              return value if value.to_s == 'absent'
              #{klass}(value)
            end
          end
        end
      CODE
    end
    #
    # The Size munger, munges a specified value to an Integer.
    #
    # rubocop: disable Metrics/AbcSize
    # rubocop: disable Metrics/CyclomaticComplexity
    module Size
      # @private
      def unsafe_munge(size)
        return super(size) if size.to_s == 'absent'
        return size if size.is_a?(Numeric)
        case size
        when /^\d+(K|k)$/ then size.chop.to_i * 1024
        when /^\d+(M|m)$/ then size.chop.to_i * 1024 * 1024
        when /^\d+(G|g)$/ then size.chop.to_i * 1024 * 1024 * 1024
        when /^unlimited$/i then 'unlimited'
        when /^\d+$/ then size.to_i
        else
          raise('invalid size')
        end
      end
    end
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/CyclomaticComplexity

    #
    # The Boolean munger, munges a specified value to a Boolean.
    #
    module Boolean
      # @private
      # rubocop: disable Lint/BooleanSymbol
      def unsafe_munge(value)
        if resource_api_available? && self.class.data_type
          super
        else
          return true if [true, 'true', :true, :yes, 'yes'].include?(value)
          return false if [false, 'false', :false, :no, 'no', :undef, nil].include?(value)
          fail "Invalid value found. #{value} is not a valid boolean."
        end
      end
      # rubocop: enable Lint/BooleanSymbol
    end

    #
    # The Upcase and downcase munger, munges a specified value to an specified String
    # If the value is an array, all entries in the array will be managed
    # If the value doesn't support the method, a debug message is send and the original value
    # is returned.
    #
    [:downcase, :upcase, :capitalize].each do |method|
      klass = method.to_s.capitalize
      module_eval(<<-CODE, __FILE__, __LINE__ + 1)
        # @nodoc
        # @private
        module #{klass}
          def unsafe_munge(entry)
            if entry.is_a?(::Array)
              entry.collect{|e| #{method}_if_defined(e)}
            else
              #{method}_if_defined(entry)
            end
          end

          private

          def #{method}_if_defined(value)
            if value.respond_to?(:#{method})
              value.#{method}
            else
              Puppet.debug "Found an unsupported #{method} munge."
              value
            end
          end
        end
      CODE
    end
  end
end
