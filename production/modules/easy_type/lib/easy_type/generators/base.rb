#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type/path_helpers'
require 'easy_type/helpers' # We need the camelize

module EasyType
  module Generators
    # docs
    class Base
      include EasyType::PathHelpers
      include EasyType::Helpers

      def self.load(generator)
        # rubocop: disable Style/EvalWithLocation
        require "easy_type/generators/#{generator}_generator"
        generator_name = camelize(generator)
        eval("EasyType::Generators::#{generator_name}Generator")
        # rubocop: enable Style/EvalWithLocation
      rescue LoadError
        raise "Generator easy_type/generators/#{generator} not found."
      end

      def initialize(type_name, options)
        @name         = type_name
        @force        = options.fetch(:force) { false }
        #
        # use not because the parser automaticlay create a false when no-comments is specified
        #
        @no_comments  = !options.fetch(:no_comments) { true }
        check_context
      end

      #
      # Run the scaffolder
      # It created the directories and the nescessary files
      #
      def run
        create_type_directory
        create_provider_directory
      end

      #
      # Create the directory where all the type code resides
      #
      def create_type_directory
        create_directory type_directory
      end

      #
      # Create the directory where all providers for the specified type reside.
      #
      def create_provider_directory
        create_directory provider_directory
      end

      private

      #
      # Check context
      #
      def check_context
        return if puppet_lib?
        raise "No puppet library path found at #{puppet_lib}. Use --force if you want to continue any way" unless @force
        Puppet.notice "No standard puppet library found at #{puppet_lib}. But because you specified --force, we will create one."
      end
    end
  end
end
