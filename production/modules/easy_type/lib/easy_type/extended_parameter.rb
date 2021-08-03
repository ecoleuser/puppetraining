#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type'

#
# Define all common mungers available for all types
#
module EasyType
  module ExtendedParameter
    # @private
    def self.included(parent)
      parent.extend(EasyType::Parameter::ClassMethods)
      parent.extend(ClassMethods)
    end

    def insync?(is)
      # work around https://tickets.puppetlabs.com/browse/PUP-2368
      if self.class.is_a_boolean_kind?
        should_value = @should ? @should.first : @should
        is == should_value
      else
        super
      end
    end


    def unsafe_munge(value)
      self.class.coerce(value)
    end

    module ClassMethods
      #
      # Basic implementation for coercing a value to the correct type.
      #
      def coerce(value)
        return value unless data_type && Puppet.const_defined?(:ResourceApi)

        # Get inside element type for the array ones when the elements are
        # checked one by one
        element_type = if array_data_type? && value && value_not_array?(value)
                         element_type_string = data_type.to_s.scan(/Array\[(.*?)[\]\[]/).dig(0,0)
                         Puppet::Pops::Types::TypeParser.singleton.parse(element_type_string)
                       else
                         data_type
                       end
        # Get resource name from the class
        resource_name = to_s.split('::')[2].downcase

        begin
          value = Puppet::ResourceApi::DataTypeHandling.mungify(
            element_type,
            value,
            "#{resource_name}.#{@name}", # type_name needs to be added for error reporting
            true
          )
          if is_a_boolean_kind? 
            # work around https://tickets.puppetlabs.com/browse/PUP-2368
            value ? :true : :false # rubocop:disable Lint/BooleanSymbol
          else
            value
          end
    
          rescue Puppet::ResourceError => e
          #
          # Because a this point in time pupet does not
          # sync the data types to agents, we can run into issues
          # with missing data types. To bypass this, we just "eat"
          # these error's and let them pass.
          # See issue https://tickets.puppetlabs.com/browse/PUP-7197 
          #
          # This means no type checking is done when the types are not available.
          #
          raise unless e.message =~ /references an unresolved type/
          value
        end
      end

      def is_a_boolean_kind?
        return true if data_type.is_a?(Puppet::Pops::Types::PBooleanType)
        return true if data_type.is_a?(Puppet::Pops::Types::POptionalType) && data_type.type.is_a?(Puppet::Pops::Types::PBooleanType)
        false
      end
      #
      # Check if the provided value is not an array
      #
      def value_not_array?(value)
        !value.is_a?(Array)
      end

      #
      # Check if the main declared data type is array. Because it is seldom a regular array
      # we have extended the check to be optional and either be 'absent' or an array of anything.
      #
      def array_data_type?
        array_type = Puppet::Pops::Types::TypeParser.singleton.parse("Optional[Variant[Enum['absent'],Array[Any]]]")
        array_type.assignable?(data_type)
      end

      #
      # Parse data_type provided in parameter.
      # In ex. value_data('Boolean')
      #
      def data_type(type = nil)
        return @data_type if type == nil
        @data_type ||= Puppet::Pops::Types::TypeParser.singleton.parse(type)
      end

      def newvalues(*names)
        return if resource_api_available? && data_type
        super
      end

      def aliasvalue(*values)
        return if resource_api_available? && data_type
        super
      end

    end
  end
end
