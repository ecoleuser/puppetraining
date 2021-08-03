#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'puppet/face'
require 'easy_type/generators/base'

Puppet::Face.define(:type, '0.0.1') do
  action(:scaffold) do
    default

    option '--provider NAME', '-p NAME' do
      summary 'Name of the provider to create. '
      description <<-DESC
        Name of the provider to create.
      DESC
    end

    option '--description DESC', '-d DESC' do
      summary 'Description of custom type.'
      description <<-DESC
        A description of the custom type you are creating.
      DESC
    end

    option '--namevar VAR', '-n VAR' do
      summary 'Name variable to use. Default is name'
      description <<-DESC
        Name variable to use. Default is name. This means the type will have a namevar
        named with the specified name.
      DESC
    end

    summary 'Create a scaffold for custom types and providers'

    description <<-DESC
      Create the correct directories and files for a custom type and
      a custom provider.
    DESC

    examples <<-'DESC'
      To create a scaffold for a new custom easy type, enter:

      $ puppet type scaffold easy_type type_name

      This creates the following files:
        - lib/puppet/type/type_name.rb
        - lib/puppet/type/type_name/name.rb
        - lib/puppet/provider/type_name/simple.rb

    DESC

    arguments '<scaffold_type> <custom_type_name>'

    when_invoked do |scaffold_name, name, options|
      Object.send(:remove_const, :GeneratorClass) if defined?(GeneratorClass) # Just to remove any warnings
      GeneratorClass = EasyType::Generators::Base.load(scaffold_name)
      generator = GeneratorClass.new(name, options)
      generator.run
      nil
    end
  end
end
