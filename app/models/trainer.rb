class Trainer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates_uniqueness_of :name
end