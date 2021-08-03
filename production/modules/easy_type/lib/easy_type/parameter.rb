#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

module EasyType
  #
  # This module contains all extensions for the Parameter class used by EasyType
  # To use it, include the following statement in your parameter of property block
  #
  #   include EasyType::Parameter
  #
  #
  module Parameter
    # @private
    def self.included(parent)
      parent.extend(ClassMethods)
    end

    # @private
    module ClassMethods
      #
      # This method is needed to support legacy puppet versions which do not
      # support munging in Puppet::ResourceApi. It returns nil.
      #
      def data_type(_type_string)
        nil
      end
      #
      # retuns the string needed to modify this specific property of a defined type
      #
      # @example
      #
      #  newproperty(:password) do
      #    on_apply do
      #      "identified by #{resource[:password]}"
      #    end
      #  end
      #
      # @param [Method] block The code to be run on creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      # @see on_create  For information on creating a resource
      # @see on_modify  For information on modifying an existing resource
      #
      def on_apply(&block)
        fail_if_competing_method_defined
        define_method(:on_apply, &block) if block
      end

      # a property callback that alows you to do certain actions before the resource
      # is actualy created or modified.
      #
      # @example
      #
      #  newproperty(:password) do
      #    before_apply do
      #      sql(so somthing we need to do before)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #
      # @see on_apply For information on creating or modifying a resource
      # @see on_create For information on creating a resource
      # @see on_modify For information on modifying an existing resource
      #
      def before_apply(&block)
        define_method(:before_apply, &block) if block
      end

      # a property callback that alows you to do certain actions after the resource
      # is actualy created or modified.
      #
      # @example
      #
      #  newproperty(:password) do
      #    before_apply do
      #      sql(so somthing we need to do before)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #
      # @see on_apply For information on creating or modifying a resource
      # @see on_create For information on creating a resource
      # @see on_modify For information on modifying an existing resource
      #
      def after_apply(&block)
        define_method(:after_apply, &block) if block
      end

      # a property callback that alows you to do certain actions before the resource
      # is actualy created.
      #
      # @example
      #
      #  newproperty(:password) do
      #    before_create do
      #      sql(so somthing we need to do before)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #
      # @see on_apply For information on creating or modifying a resource
      # @see on_create For information on creating a resource
      # @see on_modify For information on modifying an existing resource
      #
      def before_create(&block)
        define_method(:before_create, &block) if block
      end

      # a property callback that alows you to do certain actions after the resource
      # is actualy created.
      #
      # @example
      #
      #  newproperty(:password) do
      #    after_create do
      #      sql(so somthing we need to after the resource is created)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #
      # @see on_apply For information on creating or modifying a resource
      # @see on_create For information on creating a resource
      # @see on_modify For information on modifying an existing resource
      #
      def after_create(&block)
        define_method(:after_create, &block) if block
      end

      # a property callback that alows you to do certain actions before the resource
      # is actualy modfied.
      #
      # @example
      #
      #  newproperty(:password) do
      #    before_modify do
      #      sql(so somthing we need to do before modifying the resource)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #
      # @see on_apply For information on creating or modifying a resource
      # @see on_create For information on creating a resource
      # @see on_modify For information on modifying an existing resource
      #
      def before_modify(&block)
        define_method(:before_modify, &block) if block
      end

      # a property callback that alows you to do certain actions after the resource
      # is actualy modfied.
      #
      # @example
      #
      #  newproperty(:password) do
      #    after_modify do
      #      sql(so somthing we need to do after modifying the resource)
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #      #
      def after_modify(&block)
        define_method(:after_modify, &block) if block
      end

        # a property callback that allows you to do certain actions before the resource
      # is actualy destroyed.
      #
      # @example
      #
      #  newproperty(:password) do
      #    before_destroy do
      #      # we need to do before destroying the resource
      #    end
      #  end
      #
      # @param [Method] block The code to be run before destroying a resource.
      # @returns nothing.
      #
      #
      def before_destroy(&block)
        define_method(:before_destroy, &block) if block
      end

      #
      # a property callback that allows you to do certain actionsin the destroy sequence
      #
      # @example
      #
      #  newproperty(:password) do
      #    on_destroy do
      #      # do something
      #    end
      #  end
      #
      # @param [Method] block The code to be run when destroying a resource. 
      #
      #
      def on_destroy(&block)
        define_method(:on_destroy, &block) if block
      end

      # a property callback that allows you to do certain actions after the resource
      # is actualy destroyed.
      #
      # @example
      #
      #  newproperty(:password) do
      #    after_destroy do
      #      # Do something after the type destroy has been called
      #    end
      #  end
      #
      # @param [Method] block The code to be run before creating or modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      # @returns nothing.
      #      #
      def after_destroy(&block)
        define_method(:after_destroy, &block) if block
      end

      #
      # Basic implementation for coercing a value to the correct type.
      #
      def coerce(value)
        value
      end

      # @nodoc
      def fail_if_competing_method_defined
        %w(on_create on_modify).each do |method_name|
          raise "method #{method_name} can not coexist with on_apply. Use one or the other" if called_before(method_name)
        end
      end

      def called_before(method_name)
        method_defined? method_name
      end

      #
      # retuns the string needed to create this specific property of a defined type. This
      # method is **ONLY** called when the resource is created. It is not allowed to have
      # both an `on_apply` and a `on_create` definition on the type.
      #
      # @example
      #
      #  newproperty(:password) do
      #    on_create do
      #      "identified by #{resource[:password]}"
      #    end
      #  end
      #
      # @param [Method] block The code to be run on creating a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      # @see on_create on the type for information on creating a resource
      #
      def on_create(&block)
        define_method(:on_create, &block) if block
      end

      #
      # retuns the string needed to modify this specific property of a defined type. This
      # method is **ONLY** called when the resource is modified. It is not allowed to have
      # both an `on_apply` and a `on_destroy` definition on the type.
      #
      # @example
      #
      #  newproperty(:password) do
      #    on_modify do
      #      "identified by #{resource[:password]}"
      #    end
      #  end
      #
      # @param [Method] block The code to be run modifying a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      # @see on_modify on the type for information on modifying an existing resource
      #
      def on_modify(&block)
        define_method(:on_modify, &block) if block
      end

      #
      # maps a raw resource to retuns the string needed to modify this specific property of a type
      #
      # @example
      #
      #  newproperty(:password) do
      #    map do
      #     "identified by #{resource[:password]}"
      #    end
      #  end
      #
      # @param [Method] block The code to be run to pick a part of the raw_hash and use it as the value of this parameter
      #                 or property.
      #
      def to_translate_to_resource(&block)
        eigenclass = class << self; self; end
        eigenclass.send(:define_method, :translate_to_resource, &block)
      end
    end
  end
end
