#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true
#
#
# The function `ordered_steps` allows you to include a number of classes
# and make sure that they are called in this order. The `ordered_steps` allows
# a customer to easy add functionality to an included class by defining a `before` or `after` 
# class. A customer can also decide it needs to skip the class. 
# 
# Besides the default call, you can also add multiple options to the include. For example the `onlyif` clause.
# Here is an example on how to use that:
# 
#   ```puppet
#   ordered_steps[
#     'my_class::step_1',
#     'my_class::step_2',
#     ['my_class::step_4', onlyif => $if_we_want_step_4],
#   ]
#   ```
# An other option is the 'implementation' option. This options allows you to specify an defined type as the
# implementation of the logic. This is usefull when you have a lot included classes tha do the same, but need
# or have a different name. The specified class will be generated and only contain the a call to the defined type.
# The title of the defined type, will be the same as the name of the generated class.
#
# Here is an example on how to use that:
# 
#   ```puppet
#   ordered_steps[
#     'my_class::step_1',
#     ['my_class::packages', implementation => 'easy_type::packages'],
#   ]
#   ```
#
# The final option is the 'contain' option. With this option you can specify containment for the class. It can
# either be 'contain' of 'include'. The default is 'contain'.
#
# Here is an example on how to use that:
# 
#   ```puppet
#   ordered_steps[
#     'my_class::step_1',
#     ['my_class::packages', implementation => 'easy_type::packages'],
#   ]
#   ```
#
# ## Normal operation
#
# In normal operation, the classes `my_class::step_1` and `my_class::step_2` get 
# called in that order. 
#
# ## Adding a before class
#
# Let's say a customer really likes all the code, but wants
# to add just a little bit of code before step 1. To enable this, we add a variable
# to the definition of the class.
#
#   ```puppet
#   class myclass(
#      Optional[String] $before_step_1 = 'my_class::my_own_class' ,
#      Optional[String] $before_step_2,
#    ){
#   ```
# 
# Now the step will call the `my_class::my_own_class` class
# before it wil call the class `my_class::step_1`.
#
# In this example we used a hardcoded value in the class definirion. You can of course
# also use a hier variable. The `ordered_steps` will also recognise a local variable before
# call the `ordered_steps`
#
# ## Adding an after class
#
# An other use case. A customer want's to do something after step 3. 
# To enable this, we add a variable to the definition of the class.
#
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $after_step_3 = 'my_class::my_own_after_class' ,
#      ...
#    ){
#   ```
# 
#  Now after class `my_class::step_3` is applied, class `my_class::my_own_after_class`
#  will be applied.
#
# ## Skipping the class
#
# And another case. The user doen't want to use the class `my_class::step_2`. They
# have already implemented the same behaviour somewhere else in the manifest
# and just want to skip it. Again let's add a variable.
# 
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $step_2 = 'skip' ,
#      ...
#    ){
#   ```
# 
# Now class `my_class::step_2` is not added to the manifest.
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
# Sometimes customers have very specific requirements that are not met by
# the standard defined class. In that case we would like to replace the
# current class with a customer specific implementation. Again let's add
# some values to the definition:
# 
#   ```puppet
#   class myclass(
#      ...
#      Optional[String] $step_2 = 'my_class::my_own_implementatio' ,
#      ...
#    ){
#   ```
# 
# Now NOT the class `my_class::step_2` is called, but instead the user
# supplied class `my_class::my_own_implementation` is called.
#
Puppet::Functions.create_function('easy_type::ordered_steps', Puppet::Functions::InternalFunction) do

    dispatch :ordered_steps do
      scope_param
      required_param 'Array[Variant[String[1], Tuple[ String[1], Hash[String[1], Any]]]]', :names
    end
  
    def ordered_steps(scope, steps)
      steps.reduce(nil) do | previous_class, entry|
        execute_step = true # Default
        if advanced_syntax?(entry)
          full_step_name = entry[0]
          options = entry[1]
          execute_step   = options.delete('onlyif') { true }
          implementation = options.delete('implementation')
          containment    = options.delete('containment') || 'contain'
          fail "containment option '#{containment}'' is invalid." unless ['contain', 'include'].include?(containment)
          if options.keys != []
            fail "'ordered_steps' called with unknown options: #{options.keys.join(',')}"
          end
        elsif entry.is_a?(Array)
          full_step_name = entry[0]
          execute_step   = entry[1]
          implementation = nil
          containment    = 'contain'
        elsif
          full_step_name = entry
        end
  
        elements        = full_step_name.split('::')
        size            = elements.size
        step            = elements[-1]
        base_class_name = elements[0, size-1].join('::')
  
        step_class_name   = scope[step] || "#{base_class_name}::#{step}"
        before_class_name = scope["before_#{step}"]
        after_class_name  = scope["after_#{step}"]
  
        if execute_step
          if step_class_name == 'skip'
            Puppet.debug "Skipping step #{step} because it is marked as skip"
            raise "defined before_#{step} not allowed when skipping class." if before_class_name 
            raise "defined after_#{step} not allowed when skipping class." if after_class_name 
            next previous_class
          else
            create_proxy_class(scope, full_step_name, implementation) if implementation
          end
          Puppet.debug "step class #{step} replaced by #{step_class_name}." if step_class_name !=  "#{base_class_name}::#{step}"
        else
          Puppet.debug "Skipping step #{step} because of specified condition"
          raise "defined before_#{step} class not allowed when condition is false." if before_class_name 
          raise "defined after_#{step} class not allowed when condition is false." if after_class_name 
          raise "defined #{step} class as skipped not allowed when condition is false." if scope[step] == 'skip'
          raise "defined #{step} class not allowed when condition is false." if scope[step]
          next previous_class
        end
  
        if before_class_name
          insert_class_before(before_class_name, step_class_name, scope)
          add_relation(previous_class, before_class_name, scope)
        else
          contain(step_class_name, scope)
          add_relation(previous_class, step_class_name, scope)
        end
        if after_class_name
          insert_class_after(after_class_name, step_class_name, scope)
          next after_class_name
        else
          contain(step_class_name, scope)
        end
        step_class_name
      end
    end
  
    def advanced_syntax?(value)
      value.is_a?(Array) && value[1].is_a?(Hash)
    end
  
    def insert_class_before(first_class, second_class, scope)
      Puppet.debug "Class #{first_class} added before #{second_class}."
      contain(first_class, scope)
      contain(second_class, scope)
      add_relation(first_class,second_class, scope)
    end
  
    def insert_class_after(first_class, second_class, scope)
      Puppet.debug "Class #{first_class} added after #{second_class}."
      contain(second_class, scope)
      contain(first_class, scope)
      add_relation(second_class,first_class, scope )
    end
  
    def contain(class_name, scope)
      call_function_with_scope( scope, 'contain', class_name)
    end
  
    def create_proxy_class(scope, name, implementation)
      if implementation_class_exists?(scope, name)
        Puppet.debug "skipping proxy class definition. Class #{name} already exists."
        return
      end
      puppet_code = <<-PUPPET_CODE
      class #{name}(){
        #{implementation} { "#{name}":
          calling_class => '#{name}',
        }
      }
      PUPPET_CODE
      evaluate_puppet(puppet_code)
    end
  
    def implementation_class_exists?(scope, name)
      call_function('defined', name)
    end

    def evaluate_puppet(puppet_code)
      call_function('easy_type::evaluate_puppet', puppet_code)
    end


    def add_relation( source, target, scope)
      return if source.nil?
      catalog = scope.catalog
      source_class = class_reference(catalog, source)
      before = source_class['before'] || []
      before << "Class[#{sanitized_class_name(target)}]"
      source_class['before'] = before
    end
  
    def sanitized_class_name(name)
      name = name[0,2] == '::' ? name[2, name.size - 2] : name
      Puppet::Resource.new('Class', name).title
    end
  
    def class_reference(catalog, name)
      catalog.resource('Class', sanitized_class_name(name))
    end
  end
  