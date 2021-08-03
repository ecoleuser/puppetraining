# frozen_string_literal: true

newproperty(:property_without_on_apply) do
  include EasyType

  before_create do
  end

  on_create do
    'on_create called'
  end

  after_create do
  end

  before_modify do
  end

  on_modify do
    'on_modify called'
  end

  after_modify do
  end
end
