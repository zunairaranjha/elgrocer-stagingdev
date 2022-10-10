class PaymentThreshold < ActiveRecord::Base
  belongs_to :order, optional: true
  belongs_to :employee, optional: true

end
