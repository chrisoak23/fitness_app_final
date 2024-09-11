class Goal < ApplicationRecord
  validates :goal, presence: true
  validates :sport, presence: true
end