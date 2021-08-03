#
# See the file "LICENSE" for the full license governing this code.
#
#++--++
#--++--
define easy_type::secure::ensure_benchmark(
  Easy_type::Baseline_type $benchmark,
  Optional[String[1]]      $product_version,
  Optional[String[1]]      $doc_version,
  Array                    $skip_list,
)
{
  #
  # because sometimes we get unexplained "class already defined" messages, we allow users to
  # override the class generation feature. By default we DO generate the class names. When the hiera variable
  # `easy_type::generate_reference_classes` is set to `false` we skip this.
  #
  $generate_reference_classes = lookup('easy_type::generate_reference_classes', Boolean, undef, true )
  if $product_version and $doc_version{
    easy_type::validate_versions($caller_module_name, $benchmark, $product_version, $doc_version)
    $control_map     = lookup("${caller_module_name}::control_map")

    $sanitized_doc_version = regsubst($doc_version,/\./,'_','G').downcase

    echo {"Apply ${caller_module_name} ${benchmark.upcase} controls from ${product_version} ${doc_version} on ${title}.": withpath => false,}

    #
    # Now call back to the original module and see if we need to filter out some of the controls
    #
    $current_controls = call("${caller_module_name}::filter_controls", $title, $control_map)

    $current_controls.each |String[1] $control_id, String[1] $control_name | {
      $sanitized_control_id = regsubst($control_id,'-','','G').downcase
      $control_class_name = "${caller_module_name}::${product_version}::${sanitized_doc_version}::${sanitized_control_id}::${title.downcase}"

      $control_action_all = lookup("${caller_module_name}::controls::${control_name}", String, undef, 'noskip' )
      $control_action_db  = lookup("${caller_module_name}::controls::${control_name}::${title.downcase}", String, undef, 'noskip' )

      if $control_action_all == 'skip' {
        debug("${control_name} for all instances skipped")
      } elsif $control_action_db == 'skip' or $control_name in $skip_list {
        debug("${control_name} for instance: ${title} skipped")
      } else {
        if $generate_reference_classes {
          debug 'Generating reference classes...'
          # Generate puppet puppet_code
          $puppet_code = @("PUPPET")
            class ${control_class_name} {
              ${caller_module_name}::controls::${control_name} { "${title}": }
            }
          PUPPET
          easy_type::evaluate_puppet($puppet_code)
          include $control_class_name
        } else {
          debug 'Skip generating reference classes...'
          create_resources("${caller_module_name}::controls::${control_name}", { $title => {}})
        }
      }
    }
  } else {
    warning('skipping because product_version and/or doc_version is not set or found. Might be running on next run.')
  }
}
