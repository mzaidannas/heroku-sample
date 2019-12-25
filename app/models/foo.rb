class Foo < ApplicationRecord
  belongs_to :options, polymorphic: true
  accepts_nested_attributes_for :options
end
