class ShopperAgreement < ActiveRecord::Base
  belongs_to :shopper, optional: true
end

