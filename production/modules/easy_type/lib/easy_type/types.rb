#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

#
#
# Define some common data types
#
module EasyType
  #
  # The Integer munger, munges a specified value to an Integer.
  #
  module Types
    module Integer
      def self.included(parent)
        parent.include( EasyType::Mungers::Integer)
        parent.include( EasyType::Validators::Integer)
        parent.extend(ClassMethods)
      end

      module ClassMethods
        def coerce(value)
          Puppet::Pops::Utils.to_n(value)
        end
      end
    end

    module Float
      def self.included(parent)
        parent.include( EasyType::Mungers::Float)
        parent.include( EasyType::Validators::Float)
        parent.extend(ClassMethods)
      end

      module ClassMethods
        def coerce(value)
          Puppet::Pops::Utils.to_n(value)
        end
      end
    end
  end
end
