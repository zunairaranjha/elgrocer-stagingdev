class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true
  validates_presence_of :current_time_zone

  has_many :shop_product_logs, as: :owner
  belongs_to :role, optional: true
end
