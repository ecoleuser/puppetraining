#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:entitled_module) do
  include EasyType

  desc <<-DESC
  The Puppet module you want to entitle on specified node.
  DESC

  isnamevar

end
