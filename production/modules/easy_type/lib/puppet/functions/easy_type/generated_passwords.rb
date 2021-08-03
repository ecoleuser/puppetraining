#
# See the file "LICENSE" for the full license governing this code.
#
# This is a hiera backend function. It's job is to generate passwords for specfied keys.
# When the `mode` is `development` or `silent`, a password is generated. When the `mode`
# is `production`, no value is generated a a `key_not_found` is passed to the caller. This
# will probably fail te calling puppet module.
#
# To determine the mode, it'll look for a hiera key. The default key used is: `easy_type::generate_password_mode`.
# using the option `mode_key`, you can specify your own key to be used to determine the mode of
# operation.
#
# To specify the keys it will generate passwords for, use the option `use_for`. This must be a
# Hash. The key must contain a regular expression specifying the keys that need a generated password.
# The value of the hash must be the format used to generate the password. The next formats
# are available:
#
# - A -> Uppercase characters
# - a -> Lowercase characters
# - 1 -> Numbers
# - # -> Special characters
#
# The length of the password can bes pecified by using a . followed by the length. When
# no length is specified, the length is 8.
#
# Some examples:
#
# - Aa.12   -> Lowercase and uppercase characters of a length 12
# - Aa1#.9 -> Lowercase, uppercase, numbers and special characters of a length 9
#
# Sometimes you might want the password to be hashed by the password hashing function.
# You can do this by using format:
#
#  hash(Aa1$.9,sha-256)
#
# where the first parameter is a regular format, and the second parameter is the type of hash to use.
#
#
# To make sure we also work on older versions of Ruby, here our own simple dig implementation
#
if RUBY_VERSION < '2.3'
  class ::Hash
    def dig(key, *rest)
      value = self[key]
      if value.nil? || rest.empty?
        value
      elsif value.respond_to?(:dig)
        value.dig(*rest)
      else
        fail TypeError, "#{value.class} does not have #dig method"
      end
    end
  end
end

Puppet::Functions.create_function('easy_type::generated_passwords', Puppet::Functions::InternalFunction) do
  dispatch :generated_passwords do
    scope_param
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    # param 'Puppet::LookupContext', :context
    param 'Any', :context
  end

  def generated_passwords(scope, key, options, context)
    setup(scope, key, options, context)
    return context.not_found unless manage_key?(key)

    message = "Running in #{mode} mode. Using generated password for key #{key} with value #{generated_value}."
    message+= "Unencrypted value is: #{@original_value}" if @original_value

    case mode
    when 'production'
      context.explain { 'We are in production mode, so no passwords are generated.' }
      return context.not_found
    when 'silent'
      Puppet.debug message
      context.explain { 'We are in silent mode, so generating password.' }
      generated_value
    when 'development'
      Puppet.info message
      context.explain { 'We are in development mode, so generating password.' }
      generated_value
    end
  end

  def manage_key?(key)
    @generate_keys_for.keys.any? { |k| key =~ Regexp.new(k) }
  end

  def format_for(key)
    @generate_keys_for.select { |k, _v| key =~ Regexp.new(k) }.values.first
  end

  def setup(scope, key, options, context)
    @scope   = scope
    @key     = key
    @options = options
    @context = context
    @original_value    = nil
    @generate_keys_for = @options.fetch('use_for') do
      fail 'Specify \'use_for\' Hash in options for hiera backend.'
    end
    fail 'use_for key should be a Hash, with regex keys and a format as value.' unless @generate_keys_for.is_a?(Hash)

    @mode_key = @options .fetch('mode_key') { 'easy_type::generate_password_mode' }
    # The original list was "#-_.,;:+!*|~^<>=", but oracle only handle a subset well.
    @special_chars = '#:_'.split(//)
  end

  # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def generated_value
    # Passwords are generated based on the local mac address
    macaddress       = @scope.lookupvar('macaddress').delete(':')
    dmi              = @scope.lookupvar('dmi')
    uuid             = dmi && dmi.dig('product','uuid')
    uuid             = uuid.nil? ? '' : uuid.delete('-')
    seed             = "#{macaddress}#{uuid}#{@key}".bytes.inject(0) { |sum, x| sum + x }
    random           = Random.new(seed)
    requested_format = format_for(@key)
    length           = requested_format.scan(/\.(\d+)/).first
    #
    # Default length is 8
    #
    length           = length.nil? ? 8 : length.first.to_i
    fail 'Password length in format must be higher then 4.' if length < 4
    charset = []
    charset << ('A'..'Z').to_a if want_lowercase?
    charset << ('a'..'z').to_a if want_uppercase?
    charset << ('0'..'9').to_a if want_nummeric?
    charset << @special_chars if want_special_char?
    charset.flatten!
    password  = Array.new(length) { charset.sample(:random => random) }.join
    #
    # Although the above, might create a password with the correct type of characters,
    # there is no guarantee. To make sure it always has at least one of the required
    # characters, check for this and add one if needed. This is also not totaly fail safe,
    # but will suffice for now.
    #
    password[0] = 'q' if password[0] =~ /[0-9]/ # We don't want a number as first character
    password[1] = 'X' if !(password =~ /[A-Z]/) && want_uppercase?
    password[2] = 'j' if !(password =~ /[a-z]/) && want_lowercase?
    password[3] = '6' if !(password =~ /[0-9]/) && want_nummeric?
    password[4] = '#' if !(password =~ /[#{Regexp.escape(@special_chars.join)}]/) && want_special_char?
    hash_type = requested_format.scan(/hash\(.*,(.*)\)/).first
    if hash_type
      @original_value = password
      call_function('pw_hash', password, hash_type.first, macaddress)
    else
      password
    end
  end
  # rubocop: enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def data_type(string)
    parser = Puppet::Pops::Types::TypeParser.singleton
    parser.parse(string)
  end

  def want_uppercase?
    format_for(@key) =~ /A/
  end

  def want_lowercase?
    format_for(@key) =~ /a/
  end

  def want_nummeric?
    format_for(@key) =~ /1/
  end

  def want_special_char?
    format_for(@key) =~ /#/
  end

  def mode
    #
    # When the `use_for` hash contains something that matches the current key, we get a
    # dataBindin error. In those cases, return the default value as well.
    begin
      call_function('lookup', @mode_key, data_type("Enum['production', 'silent', 'development']"), 'first', 'production')
    rescue Puppet::DataBinding::LookupError
      'production'
    end
  end
end
