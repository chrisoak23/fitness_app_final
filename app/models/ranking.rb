class Ranking < ApplicationRecord
  belongs_to :user
  belongs_to :anime

  validates :score, presence: true, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10
  }
  validates :user_id, uniqueness: { scope: :anime_id, message: "has already ranked this anime" }
end
