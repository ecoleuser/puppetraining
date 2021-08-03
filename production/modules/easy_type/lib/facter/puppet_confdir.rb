#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'facter'
require 'puppet'
#
# Pass the name of the Puppet setting confdir as a fact
#
Facter.add('puppet_confdir') do
  setcode do
    Puppet.settings[:confdir]
  end
end
