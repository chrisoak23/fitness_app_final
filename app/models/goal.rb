class Goal < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  validates :sport, presence: true
end