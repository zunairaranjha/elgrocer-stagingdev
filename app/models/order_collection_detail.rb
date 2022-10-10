class OrderCollectionDetail < ActiveRecord::Base
  belongs_to :order, optional: true
  belongs_to :collector_detail, optional: true
  belongs_to :vehicle_detail, optional: true
  belongs_to :pickup_location, optional: true
  belongs_to :pickup_loc, optional: true, foreign_key: "pickup_location_id"

  enum collector_statuses: {
    "on_the_way" => 1,
    "at_the_store" => 2
  }
end