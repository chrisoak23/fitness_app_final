class Goal < ApplicationRecord
  validates :name, presence: true
  validates :sport, presence: true
end