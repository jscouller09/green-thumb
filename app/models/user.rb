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
  has_many :gardens
  has_many :tasks
  has_many :messages
  has_many :conversations, through: :user_conversations


  #method to access user full name
  def full_name
    "#{first_name} #{last_name}"
  end
end
