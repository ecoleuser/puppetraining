#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
#
# The function `staged_contain` allows you to stage a number of classes
# and make sure that they are called in this order. The `staged_contain` allows
# a customer to easy add functionality to a stage by defining a `before` or `after` 
# class. A customer can also decide it needs to skip the class. 
# 
# Besides the default call, you can also add a condition to stage. This means the 
# stage will only be part of the sequence if the condition is `true`. This helps in keeping
# a simple flow of classes, but still have conditional classes.
# 
# Here is an example:
# 
#   ```puppet
#   staged_contain[
#     'my_class::stage_1',
#     'my_class::stage_2',
#     'my_class::stage_3',
#     ['my_class::stage_4', $if_we_want_stage_4],
#   ]
#   ```
#
# ## Normal operation
#
# In normal operation, the classes `my_class::stage_1` and `my_class::stage_2` get 
# called in that order. 
#
# ## Adding a before class
#
# Let's say a customer really likes all the code, but wants
# to add just a little bit of code before stage 1. To enable this, we add a variable
# to the definition of the class.
#
#   ```puppet
#   class myclass(
#      Optional[String] $before_stage_1 = 'my_class::my_own_class' ,
#      Optional[String] $before_stage_2,
#    ){
#   ```
# 
# Now the staged contain, will call the `my_class::my_own_class` class
# before it wil call the class `my_class::stage_1`.
#
# In this example we used a hardcoded value in the class definirion. You can of course
# also use a hier variable. The staged contain will also recognise a local variable before
# call the `staged_contain`
#
# ## Adding an after class
#
# An other use case. A customer want's to do something after stage 3. 
# To enable this, we add a variable to the definition of the class.
#
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $after_stage_3 = 'my_class::my_own_after_class' ,
#      ...
#    ){
#   ```
# 
#  Now after class `my_class::stage_3` is applied, class `my_class::my_own_after_class`
#  will be applied.
#
# ## Skipping the class
#
# And another case. The user doen't want to use the class `my_class::stage_2`. They
# have already implemented the same behaviour somewhere else in the manifest
# and just want to skip it. Again let's add a variable.
# 
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $stage_2 = 'skip' ,
#      ...
#    ){
#   ```
# 
# Now class `my_class::stage_2` is not added to the manifest.
#
# ## The conditional inclusion
#
# When using the `['class', $condition_variable].` All other functionality is still there. The
# before, the after and the replacing of the class. The exception is this all **ONLY** applies
# if the specified conditionalvariable is true. If it false the class will **NOT** be included 
# in the catalog. If the conditinal value is false, providing a before, after or replacement class
# wil result in an error. Also skipping a conditional class with `skip` is not allowed.
#
# ## Replacing the implementation
#
# Sometimes customers have very specfic requirements that are not met by
# the standard defined class. In that case we would like to replace the
# current class with a customer specfic implementation.Again let's add
# some values to the definition:
# 
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $stage_2 = 'my_class::my_own_implementatio' ,
#      ...
#    ){
#   ```
# 
# Now NOT the class `my_class::stage_2` is called, but instead the user
# supplied class `my_class::my_own_implementation` is called.
#
Puppet::Functions.create_function('easy_type::staged_contain', Puppet::Functions::InternalFunction) do

  dispatch :staged_contain do
    scope_param
    required_param 'Array[Variant[String[1], Tuple[String[1], Boolean]]]', :names
  end

  def staged_contain(scope, stages)
    Puppet.warn_once('deprecations', 'easy_type::staged_contain', "function 'easy_type::staged_contain' is deprecated. Please use 'easy_type::ordered_steps'.")
    transformed_stages = stages.collect do |stage|
      if advanced_syntax?(stage)
        [stage[0], {'containment' => 'contain', 'onlyif' => stage[1]}]
      else
        stage
      end
    end
    call_function_with_scope(scope, 'easy_type::ordered_steps', transformed_stages)
  end

  def advanced_syntax?(value)
    value.is_a?(Array)
  end
end
