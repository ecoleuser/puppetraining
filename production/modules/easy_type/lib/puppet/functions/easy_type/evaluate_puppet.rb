#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
# This function allows you to dynamically add puppet code to your catalog. 
# The `puppet_code` parameter can by dynamically filled with puppet code, and
# variables can be used to construct this code. Here is an example
#
#   ```puppet
#     $my_class_name = 'my_class'
#     $show_me = 10
#     $puppet_code = @("PUPPET")
#       class ${my_class_name}
#       {
#         notice "Always want to show you ${show_me}"
#       }
#     PUPPET
#     easy_type::evaluate_puppet($puppet_code)
#     include $my_class_name
# ```
# This dynamic code is added to the current catalog and executed.
#
Puppet::Functions.create_function('easy_type::evaluate_puppet', Puppet::Functions::InternalFunction) do

  dispatch :evaluate_puppet do
    scope_param
    required_param 'String[1]', :puppet_code
  end

  def evaluate_puppet(scope, puppet_code)
    # Newer Puppet versions make it easy to compile a parly catalog, You just need:
    # 
    #   compiler = Puppet::Pal::CatalogCompiler.new(scope.compiler)
    #   compiler.evaluate_string(puppet_code)
    #
    # Because we want to support older versions of Puppet too, we use our own (borrowd ;-)) implementation,
    internal_compiler = scope.compiler
    evaluator = Puppet::Pops::Parser::EvaluatingParser.new
    ast = evaluator.parse_string(puppet_code)
    bridged = Puppet::Parser::AST::PopsBridge::Program.new(ast)
    internal_compiler.environment.known_resource_types.import_ast(bridged, "")
    bridged.evaluate(internal_compiler.topscope)
  end
end
