#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
# encoding: UTF-8

# rubocop: disable Lint/NestedMethodDefinition
# rubocop: disable Lint/DuplicateMethods
# rubocop: disable Style/MethodMissing
# rubocop: disable Metrics/ModuleLength
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/AbcSize
# rubocop: disable Style/FormatStringToken

require 'easy_type/group'

module EasyType
  #
  # This module contains all extensions used by EasyType within the type
  #
  # To use it, include the following statement in your type
  #
  #   include EasyType::Type
  #
  module Type
    # @private
    def self.included(parent)
      return if parent.is_a?(EasyType::Type::ClassMethods)
      include EasyType::FileIncluder
      parent.extend(ClassMethods)

      include_file('easy_type/disable_corrective_ensure.rb', binding)
      include_file('easy_type/disable_corrective_change.rb', binding)
  
    end

    def method_missing(meth, *args, &block)
      variable = meth.to_sym
      if known_attribute(variable)
        self[variable]
      else
        super # You *must* call super if you don't handle the
        # method, otherwise you'll mess up Ruby's method
        # lookup.
      end
    end

    def to_manifest
      # Collect list of attributes to align => and move ensure first
      attr = parameters.keys
      attr_max = attr.inject(0) { |max, k| k.to_s.length > max ? k.to_s.length : max }

      attr.sort!
      if attr.first != :ensure && attr.include?(:ensure)
        attr.delete(:ensure)
        attr.unshift(:ensure)
      end

      attributes = attr.collect do |k|
        v = self[k]
        format("  %-#{attr_max}s => %s,\n", k, Puppet::Parameter.format_value_for_display(v))
      end.join

      escaped = title.gsub(/'/, "\\\\'")
      format("%s { '%s':\n%s}", type.to_s.downcase, escaped, attributes)
    end

    # @private
    def respond_to?(meth, include_private = false)
      variable = meth.to_sym
      if known_attribute(variable)
        true
      else
        super
      end
    end

    #
    # Return the groups the type contains
    #
    # @return [Group] All defined groups
    #
    def groups
      self.class.groups
    end

    #
    # Return the defined commands for the type
    #
    # @return [Array] of [Symbol] with all commands
    #
    def commands
      self.class.instance_variable_get(:@commands)
    end

    def all_property_classes
      self.class.properties
    end

    private

    # @private
    def known_attribute(attribute)
      all_attributes = all_property_classes.map(&:name) + self.class.parameters
      all_attributes.include?(attribute)
    end

    # @nodoc
    module ClassMethods
      #
      # define a group of parameters. A group means a change in one of
      # it's members all the information in the group is added tot
      # the command
      #
      # @example
      #  group(:name) do # name is optional
      #     property :a
      #     property :b
      #  end
      # @param [Symbol] group_name the group name to use. A group name must be unique within a type
      # @return [Group] the defined group
      #
      # rubocop:disable Alias
      def group(group_name = :default, &block)
        include EasyType::FileIncluder

        @group_name = group_name # make it global
        @groups ||= EasyType::Group.new

        alias :orig_parameter :parameter
        alias :orig_property :property

        def parameter(parameter_name)
          process_group_entry(include_file("puppet/type/#{name}/#{parameter_name}"))
        end

        def property(property_name)
          process_group_entry(include_file("puppet/type/#{name}/#{property_name}"))
        end

        def process_group_entry(entry)
          @groups.add(name, entry)
        end

        yield if block

        alias :parameter :orig_parameter
        alias :property :orig_property
      end

      # rubocop:enable Alias
      #
      # Return the groups the type contains
      #
      # @return [Group] All defined groups
      #
      def groups
        @groups ||= EasyType::Group.new
        @groups
      end

      #
      # easy way to map parts of a titles to one of the attributes and properties.
      #
      # @example
      # map_titles_to_attributes([
      #   /((.*))/      , [:name, :user],
      #   /((.*)@(.*))/ , [:name, :user, :sid]
      #   ])
      #
      # @param [Array] an Array containing pairs where the fisrt entry is a regular expression and the second
      #               contains an array of symbols depicting the attributes to be mapped to
      #
      def map_titles_to_attributes(array)
        pattern_array = array.each_slice(2).map { |entry| [entry[0], entry[1].collect { |e| [e] }] }
        eigenclass.send(:define_method, :title_patterns) do
          pattern_array
        end
      end

      #
      # easy way to map parts of a title to one of the attributes and properties.
      #
      # @example
      # map_title_to_attributes([:name,:domain, :jmsmodule, :queue_name]) do
      #  /^((.*\/)?(.*):(.*)?)$/)
      # end
      #
      # @param [Array] an array containing the symbols idetifying the parameters an properties to use
      # @yield yields regexp the regular expression to map parts of the title.
      #
      # You can also pass a Hash as one of the entries in the array. The key mus be the field to map to
      # and the value mus be a closure (Proc or a Lambda) to manage the value
      #
      # @example
      # default_name = lambda {| name| name.nil? ? 'default' : name}
      # map_title_to_attributes([:name -> default_name,:domain, :jmsmodule, :queue_name]) do
      #  /^((.*\/)?(.*):(.*)?)$/)
      # end
      #
      def map_title_to_attributes(*attributes)
        if @deprecated_message.nil?
          Puppet.warning "Deprecated method easy_type::map_title_to_attributes used in custom type #{name}"
          @deprecated_message = true
        end
        attribute_array = attributes.map do |attr|
          case attr
          when Array  then attr
          when Symbol then [attr, nil]
          when String then [attr.to_sym, nil]
          when Hash   then attr.to_a.flatten
          else fail "map_title_to_attribute, doesn\'t support #{attr.class} as attribute"
          end
        end
        regexp = yield
        eigenclass.send(:define_method, :title_patterns) do
          [
            [
              regexp,
              attribute_array
            ]
          ]
        end
      end

      #
      # include's the parameter declaration. It searches for the parameter file in the directory
      # `puppet/type/type_name/parameter_name, or in the shared directory `puppet/type/shared`
      #
      # @example
      #  parameter(:name)
      #
      # @param [Symbol] parameter_name the base name of the parameter
      #
      def parameter(parameter_name)
        return include_file specific_file(parameter_name) if specific_file?(parameter_name)
        return include_file shared_file(parameter_name) if shared_file?(parameter_name)
        fail ArgumentError, "file puppet/type/#{name}/#{parameter_name} not found"
      end
      alias property parameter

      # @private
      def specific_file(parameter_name)
        get_ruby_file("puppet/type/#{name}/#{parameter_name}")
      end

      # @private
      def specific_file?(parameter_name)
        !specific_file(parameter_name).nil?
      end

      # @private
      def shared_file(parameter_name)
        #
        # For back-ward compatibility, we first search the module's private shared path
        # and then go to the overall shared path.
        #
        module_file = get_ruby_file("puppet/type/shared/#{module_name}/#{parameter_name}")
        shared_file = get_ruby_file("puppet/type/shared/#{parameter_name}")
        module_file ? module_file : shared_file
      end

      # @private
      def shared_file?(parameter_name)
        !shared_file(parameter_name).nil?
      end

      def module_name
        #
        # This default module name implementation does nothing.
        #
        ''
      end

      #
      # set's the command to be executed. If the specified argument translate's to an existing
      # class method on the type, this method will be identified as the command. When a class
      # method doesn't exist, the command will be translated to an os command
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    command do
      #     :sql
      #    end
      #
      # @param [Symbol] method_or_command method or os command name
      #
      def set_command(methods_or_commands)
        @commands ||= []
        methods_or_commands = Array(methods_or_commands) # ensure Array
        methods_or_commands.each do |method_or_command|
          @commands << method_or_command
          define_os_command_method(method_or_command) unless methods.include?(method_or_command)
        end
      end

      # @private
      def define_os_command_method(method_or_command)
        eigenclass.send(:define_method, method_or_command) do |*args|
          command = args.dup.unshift(method_or_command)
          Puppet::Util::Execution.execute(command)
        end
      end

      #
      # retuns an Array with all prefteched resources
      #
      # @example
      #    on_prefetch do
      #    end
      #
      # @param [Method] block The code to be run in provider for prefetching.
      #                 If none is specfied the default will be run
      #
      def on_prefetch(&block)
        eigenclass.send(:define_method, :execute_prefetch, &block)
      end

      #
      # retuns the string needed to start the creation of an sql type
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    on_refresh do
      #      # restart the server
      #    end
      #
      # @param [Method] block The code to be run on getting a notification
      #
      def on_notify(&block)
        define_method(:refresh, &block) if block
      end

      # @private
      def eigenclass
        class << self; self; end
      end

      #
      # Create the following callback methods:
      # before_create
      # before_update
      # after_update
      # on_create
      # on_update
      # on_update
      # after_create
      # after_update
      # after_update
      #
      [:create, :modify, :destroy].each do |action|
        [:before, :on, :after].each do |stage|
          class_eval(<<-CODE, __FILE__, __LINE__ + 1)
            # @nodoc
            # @private
            def #{stage}_#{action}(&block)
              define_method(:#{stage}_#{action}, &block) if block
            end
          CODE
        end
      end

      #
      # The code in the block is called to fetch all information of all available resources on the system.
      # Although not strictly necessary, it is a convention the return an Array of Hashes
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    to_get_raw_resourced do
      #     TODO: Fill in
      #    end
      #
      # @param [Method] block The code to be run to fetch the raw resource information from the system.
      #
      def to_get_raw_resources(&block)
        eigenclass.send(:define_method, :get_raw_resources, &block)
      end
    end
  end
end
# rubocop: enable Lint/NestedMethodDefinition
# rubocop: enable Lint/DuplicateMethods
# rubocop: enable Style/MethodMissing
# rubocop: enable Metrics/ModuleLength
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
# rubocop: enable Style/FormatStringToken
