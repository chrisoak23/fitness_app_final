class User < ApplicationRecord
  has_many :user_trainers
  has_many :trainers, through: :user_trainers
  has_many :rankings
  has_many :ranked_animes, through: :rankings, source: :anime

  before_save { self.email = email.downcase }
  has_many :goals, dependent: :destroy
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 25 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 105 },
            format: { with: VALID_EMAIL_REGEX }
  has_secure_password
end