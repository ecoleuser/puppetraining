# frozen_string_literal: true

newproperty(:second_in_group) do
  include EasyType

  on_apply do
    'second in group'
  end
end
