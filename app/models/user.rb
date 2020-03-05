class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #users has avatar
  has_one_attached :avatar

  #users must specify their first and last name
  validates :first_name, presence: true
  validates :last_name, presence: true

  #user associations
  has_many :gardens, dependent: :destroy
  has_many :plots, through: :gardens
  has_many :tasks, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :user_conversations, dependent: :destroy
  has_many :conversations, through: :user_conversations


  #method to access user full name
  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end
end
