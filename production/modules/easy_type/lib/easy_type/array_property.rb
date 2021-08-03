#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
module EasyType
  #
  # Includes all behaviour needed for an Array property
  #
  module ArrayProperty
    def unsafe_validate(value)
      raise 'You need to specify an Array instead of a comma separated string' if value =~ /,/
      self.class.coerce(value) if self.class.instance_variable_get(:@data_type)
    end

    def insync?(is)
      if is == :absent
        should.empty?
      elsif should == :absent
        is.empty?
      else
        is.sort == should.sort
      end
    end

    #
    # Print a good change message when changing the contents of an array
    #
    def change_to_s(current, should)
      current = [] if current == :absent
      should = [] if should == :absent
      message = ''
      message += "removing #{(current - should).join(', ')} " unless (current - should).inspect == '[]'
      message += "adding #{(should - current).join(', ')} " unless (should - current).inspect == '[]'
      #
      # If the array contains the same value twice e.g.  compare ['Server','Server'],
      # the current algorithm returns an empty string. In that case we use the full value.
      #
      message = "changed to #{should}" if message.empty?
      message
    end
  end
end
# rubocop: enable Metrics/AbcSize
