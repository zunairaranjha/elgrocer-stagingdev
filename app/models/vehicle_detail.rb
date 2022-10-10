class VehicleDetail < ActiveRecord::Base
  belongs_to :shopper, optional: true
  belongs_to :color, optional: true
  belongs_to :vehicle_model, optional: true
end
