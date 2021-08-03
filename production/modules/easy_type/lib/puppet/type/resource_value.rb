#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity
# rubocop: disable Metrics/PerceivedComplexity
# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/LineLength

require 'easy_type'

# TODO: Add documentation
Puppet::Type.newtype(:resource_value) do
  include EasyType

  desc <<-DESC
  The type allows you to specify individual properties of native Puppet types as resources in a Puppet catalog.

  This can be usefull when you need to add specific properties to an exsiting resource, but need to do it somewhere
  else in your puppet code. Here is an contrived example:

       file {'/etc/a.a':
         ensure => 'present',
         group  => 'root',
       }

  and in some other manifest:

      resource_value{ "File[/etc/a.a]owner":
        value => 'vagrant'
      }

  here you add the `owner` property to the resource `File[/etc/a.a]`. When you run this manifest, you will only see
  that the `File[/etc/a.a]` beeing managed once and all properties beeing set to the correct value.

  By default the `resource_value` doesn't allow you to override the existing value. So this means when the value is
  already set somewhere in the catalog. So when we try this example:

      file {'/etc/a.a':
        ensure => 'present',
        group  => 'root',
        owner  => 'root'
      }

      resource_value{ "File[/etc/a.a]owner":
        value => 'vagrant'
      }

  This happens:

      Error: /Stage[main]/Main/Resource_value[File[/etc/a.a]owner]: Resource_value[File[/etc/a.a]owner]: Property owner value already defined on File[/etc/a.a] in catalog.
      Error: Failed to apply catalog: Some pre-run checks failed

  When you want to override this behavior check the ` allow_redefine` parameter.

  By default the `resource_value` type uses an existing resource in the catalog. When you try to use `resource_value` without
  existing resource this happens:

      Error: /Stage[main]/Main/Resource_value[File[/etc/a.a]owner]: Resource_value[File[/etc/a.a]owner]: resource 'File[/etc/a.a]' not found in catalog
      Error: Failed to apply catalog: Some pre-run checks failed

  When you want `resource_value` to create the resource, you have to set the `allow_create` property to true.

  **WARNING**

  The `resource_value` is a type that can be useful in specific cases. We have build it to support CIS benchmarks in Puppet. Our
  use case was to allow the manifest writer to "just do his thing" and us to add the extra security layer. Without knowing to
  much about each other. That said. Don't over use this type. Specially the `add_value` and the `remove_value` override existing
  values without warning and searching for (logical) errors in your manifest becomes very difficult.

  DESC

  map_titles_to_attributes([
                             %r{(([A-Z].+)\[(.+)\](\w+)\/(\w+))$}, [:name, :resource_type, :resource_title, :property_name, :unique],
                             /^(([A-Z].+)\[(.+)\](\w+))$/, [:name, :resource_type, :resource_title, :property_name]
                           ])

  def delete_myself
    catalog.remove_resource(self)
  end

  def full_ref
    "#{ref} at #{file}:#{line}"
  end

  def normalized_value(resource)
    if !resource[property_name].is_a?(Array) and self[:value].size == 1
      self[:value].first
    else
      self[:value]
    end
  end

  def redefined?(resource)
    !resource[property_name].nil? && resource[property_name].to_s != normalized_value(resource).to_s
  end

  def copy_meta_parameters_to(resource)
    self.class.metaparams.each { |p| resource[p] = self[p] if self[p] }
  end

  def check_resource
    resource = catalog.resource(resource_type, resource_title)
    if resource.nil?
      raise "#{full_ref}: resource '#{resource_type}[#{resource_title}]' not found in catalog" unless allow_create
      resource = catalog.create_resource(resource_type, :name => resource_title, :ensure => ensure_value)
      #
      # For logging purposes, contain the resource in our parent.
      # We don't use self, because self will be removed from the catalog at the end.
      #
      parent = catalog.container_of(self)
      catalog.add_edge(parent, resource)
    end
    copy_meta_parameters_to(resource)
    if self[:value]
      #
      # These checks only need to be done when value is specified
      # an add_value or remove value, alomost always overrides a current value
      #
      raise "#{full_ref}: Property #{property_name} value already defined on #{resource_type}[#{resource_title}] at #{file}:#{line}" unless resource[property_name].nil? || allow_redefine
      Puppet.warning "#{full_ref}: Property #{property_name} on #{resource_type}[#{resource_title}] is currently defined as #{resource[property_name]} at #{file}:#{line}, and now redefined to #{normalized_value(resource)}" if redefined?(resource) && warnings
    else
      raise "#{full_ref}: Property #{property_name} is not an array. add_value and remove_value only work on array properties." unless resource[property_name].is_a?(::Array) || resource[property_name].nil?
    end
    resource
  end

  def pre_run_check
    resource = check_resource
    resource[property_name] = self[:value] if self[:value]
    if resource[property_name].nil?
      resource[property_name] = self[:add_value] if self[:add_value]
    else
      resource[property_name] = resource[property_name] + self[:add_value] if self[:add_value]
      resource[property_name] = resource[property_name] - self[:remove_value] if self[:remove_value]
    end
    delete_myself
  end

  parameter :name
  parameter :resource_type
  parameter :resource_title
  parameter :property_name
  parameter :allow_redefine
  parameter :allow_create
  parameter :warnings
  parameter :unique
  parameter :ensure_value

  property  :value
  property  :add_value
  property  :remove_value
end
# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/PerceivedComplexity
# rubocop: enable Metrics/AbcSize
# rubocop: enable Metrics/LineLength
