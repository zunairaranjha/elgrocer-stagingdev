class CollectorDetail < ActiveRecord::Base
  belongs_to :shopper, optional: true
end
