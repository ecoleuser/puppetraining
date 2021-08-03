#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
# encoding: UTF-8

# rubocop: disable Metrics/CyclomaticComplexity

require 'resolv'
require 'uri'
require 'easy_type'

#
# Define all common validators available for all types
#
module EasyType
  STRING_OF_DIGITS ||= /^-?\d+$/
  FQDN             ||= /(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.)+(?:[a-zA-Z]{2,})$)/
  #
  # Contains a set of generic validators to be used in any custo type
  #
  module Validators
    ##
    #
    # This validator validates if a name is free of whitespace and not empty. To use this validator, include
    # it in a Puppet name definition.
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::NameValidator
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module Name
      # @private
      def unsafe_validate(value)
        fail Puppet::Error, "Parameter #{name} may not contain whitespace: #{value}" if value =~ /\s/
        fail Puppet::Error, "Parameter #{name} may not be empty" if value.empty?
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end

    ##
    #
    # This validator validates if it is an Integer
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::Integer
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module Integer
      # @private
      def unsafe_validate(value)
        super if resource_api_available? && self.class.data_type
        return if value == 'absent'
        klass = value.class.to_s
        case klass
        when 'Integer', 'Fixnum', 'Bignum'
          return
        when 'String'
          fail Puppet::Error, "Invalid value for Integer: #{value}" unless value =~ STRING_OF_DIGITS
        else
          fail Puppet::Error, "Invalid value for Integer: #{value}"
        end
      end
      module_function :unsafe_validate
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
    end

    ##
    #
    # This validator validates if it is valid port number.
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::PortNumber
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module PortNumber
      # @private
      def unsafe_validate(value)
        return if value == 'absent'
        klass = value.class.to_s
        actual_value = case klass
                       when 'Integer', 'Fixnum', 'Bignum'
                         value.to_i
                       when 'String'
                         begin
                           Integer(value)
                         rescue ArgumentError
                           fail Puppet::Error, "#{value} is not valid as a port number"
                         end
                       else
                         fail Puppet::Error, "#{value} is not valid as a port number"
                       end
        fail Puppet::Error, "#{value} is not valid as a port number" if actual_value < 0 || actual_value > 65_535
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end

    ##
    #
    # This validator validates if it is valid IP adress
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::IPAddress
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module IPAddress
      # @private
      def unsafe_validate(value)
        return if value == 'absent'
        fail Puppet::Error, "#{value} is not valid as a IP address" unless value =~ Resolv::AddressRegex
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end

    ##
    #
    # This validator validates if it is valid FQDN with at least a domain name
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::FQDN
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module FQDN
      # @private
      def unsafe_validate(value)
        return if value == 'absent'
        fail Puppet::Error, "#{value} is not valid as a FQDN" unless value =~ EasyType::FQDN
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end

    ##
    #
    # This validator validates if it is valid FQDN with at least a domain name or an IP address
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::IPFQDN
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module IPFQDN
      # @private
      def unsafe_validate(value)
        return if value == 'absent'
        fail Puppet::Error, "#{value} is not valid as a FQDN or IP address" unless value =~ Regexp.union(EasyType::FQDN, Resolv::AddressRegex)
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end

    ##
    #
    # This validator validates if it is valid FQDN with at least a domain name or an IP address
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::Url
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module Url
      # @private
      def unsafe_validate(value)
        return if value == 'absent'
        fail Puppet::Error, "#{value} is not valid as a URL" unless value =~ /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
      end
      #
      # Allow calling the function as EasyType::Validators::<type>::unsafe_validate
      #
      module_function :unsafe_validate
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity
