class Command < ApplicationRecord
  belongs_to :category
  has_many :parameters
end
