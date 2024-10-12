class Trainer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates_uniqueness_of :name
  has_many :user_trainers
  has_many :users, through: :user_trainers
end