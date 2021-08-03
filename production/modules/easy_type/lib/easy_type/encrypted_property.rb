#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

module EasyType
  #
  # Contains the base methods for handeling an encrypted property.
  #
  module EncryptedProperty
    def self.included(parent)
      parent.extend(ClassMethods)
      parent.include( Parameter)
    end

    def insync?(_is)
      raise 'You must define the method current_value for encrypted properties' unless method(:current_value)
      current_value == should
    end

    def change_to_s(currentvalue, _newvalue)
      if currentvalue == :absent
        'created with specified value'
      else
        'changed to new value'
      end
    end

    # rubocop:disable Style/PredicateName
    def is_to_s(_currentvalue)
      '[old encrypted value]'
    end
    # rubocop:enable Style/PredicateName

    def should_to_s(_newvalue)
      '[new encrypted value]'
    end

    # Class methods for an encrypted property
    module ClassMethods
      def translate_to_resource(_raw_resource)
        '<encrypted value>'
      end

      #
      # Basic implementation for coercing a value to the correct type.
      #
      def coerce(value)
        value
      end

    end
  end
end
