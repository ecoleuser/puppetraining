# frozen_string_literal: true

newproperty(:first_in_group) do
  include EasyType

  on_apply do
    'first in group'
  end
end
