#
# See the file "LICENSE" for the full license governing this code.
#
# frozen_string_literal: true

newparam(:license_id) do
  include EasyType

  desc <<-DESC
  This is the license id you want to use for this entitlement. This is the number given to you 
  by Enterprise Modules when you purchase the entitlement subscription.
  DESC

  isnamevar

end
