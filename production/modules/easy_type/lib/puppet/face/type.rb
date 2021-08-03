#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

require 'puppet/face'
require 'easy_type/generators/base'

Puppet::Face.define(:type, '0.0.1') do
  option '--force', '-f' do
    summary 'Force overwrite of existing type and provider, if any.'
    description <<-DESC
      Force overwrite of existing type and provider, if any.
    DESC
  end

  option '--no-comments', '-c' do
    summary "Don't write the comments to the files. Just the raw code"
    description <<-DESC
      The scaffolder and generator default write a lot of comment to the files.
      If you know what you are doing, these might hinder you more then they help.
      Use  --no-comment to stop generating the comments
    DESC
  end
end
