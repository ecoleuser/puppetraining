#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

# rubocop: disable Style/RedundantSelf
module EasyType
  #
  # YamlPorperty get's its value from the yaml data based on the name of the property
  #
  #
  module YamlProperty
    def self.included(parent)
      parent.include(EasyType)
      parent.extend(ClassMethods)
      parent.include(Parameter)
    end

    #
    # Class methods for yaml based properties
    #
    module ClassMethods
      def translate_to_resource(raw_resource)
        raw_resource[self.name]
      end
    end
  end
end
# rubocop: enable Style/RedundantSelf
