#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'puppet/face'
require 'easy_type'

Puppet::Face.define(:emlicense, '0.0.1') do
  option '--puppetserver NAME', '-p NAME' do
    summary 'Name of the puppet server. '
    description <<-DESC
      Name of the puppet server.
    DESC
  end
end
