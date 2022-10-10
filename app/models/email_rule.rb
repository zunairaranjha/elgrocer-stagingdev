class EmailRule < ActiveRecord::Base

  belongs_to :promotion_code, optional: true

  validates_presence_of :category, :name

  scope :enable, -> { where(is_enable: true) }
  scope :order_reminders, -> { where(is_enable: true, category: 'Order Reminder') }
  scope :abandon_baskets, -> { where(is_enable: true, category: 'Abandon Basket') }

end
