#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
# This method makes it easy to assess local variables of any class. Just add this line to your puppet code:
#
#   easy_type::debug_evaluation()
#
# By default it will do nothing. You will need to enable this by addint the follwoing hieradata:
#
#   easy_type::extended_debugging:  true
#
# And when puppet run's with debug, the information is dumped in the debug log. The debug information looks
# like this:
#
# Debug:
# Debug: *** Start variable dump for Scope(Class[Test]) ***
# Debug: module_name = "" (String)
# Debug: caller_module_name = "" (String)
# Debug: title = "test" (String)
# Debug: name = "test" (String)
# Debug: a = "string" (String)
# Debug: b = 1 (Integer)
# Debug: c = #<Sensitive [value redacted]> (Puppet::Pops::Types::PSensitiveType::Sensitive)
# Debug: *** End variable dump for Scope(Class[Test]) ***
# Debug:
#
Puppet::Functions.create_function('easy_type::debug_evaluation', Puppet::Functions::InternalFunction) do

  dispatch :debug_call do
    scope_param
  end

  def debug_call(scope)
    return unless extended_debugging?
    local_scope = scope.effective_symtable(false)
    local_variables = local_scope.instance_variable_get(:@symbols)
    Puppet.debug ""
    Puppet.debug "*** Start variable dump for #{scope} ***"
    local_variables.each {| variable, value| Puppet.debug "#{variable} = #{value.inspect} (#{value.class})"}
    Puppet.debug "*** End variable dump for #{scope} ***"
    Puppet.debug ""
  end

  private
  def extended_debugging?
    return true
    call_function('lookup', 'easy_type::extended_debugging', data_type('Boolean'), 'first', false)
  end

  def data_type(string)
    parser = Puppet::Pops::Types::TypeParser.singleton
    parser.parse(string)
  end

end

