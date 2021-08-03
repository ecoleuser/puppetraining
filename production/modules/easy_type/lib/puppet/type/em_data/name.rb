#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:name) do
  include EasyType

  desc <<-DESC
  The name of the catalog data record
  DESC

  isnamevar
end
