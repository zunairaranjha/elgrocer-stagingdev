class OrderSubstitution < ActiveRecord::Base
  belongs_to :order, optional: true
  belongs_to :product, optional: true
  belongs_to :substituting_product, optional: true, :class_name => "Product", :foreign_key => "substituting_product_id"
  belongs_to :shopper, optional: true
  belongs_to :retailer, optional: true
  belongs_to :shop, optional: true
  belongs_to :shop_promotion, optional: true
  belongs_to :product_proposal, optional: true

  def selected(order_position, date_time_offset)
    self.is_selected = true
    self.date_time_offset = date_time_offset
    self.substitute_detail = order_position
    save
  end
end
