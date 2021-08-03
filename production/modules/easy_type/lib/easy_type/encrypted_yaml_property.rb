#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'easy_type/encryption'

module EasyType
  #
  # YamlPorperty get's its value from the yaml data based on the name of the property
  #
  #
  module EncryptedYamlProperty
    def self.included(parent)
      parent.include( EasyType)
      parent.include( EncryptedProperty)
      parent.include( Encryption)
    end

    def on_apply
      resource.current_config[name.to_s] = encrypt(value)
    end

    def current_value
      decrypted_value(is)
    end

    def is
      resource.current_config.fetch(name.to_s) { '' }
    end
  end
end
