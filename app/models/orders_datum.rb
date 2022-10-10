class OrdersDatum < ApplicationRecord
  belongs_to :order, optional: true

  def self.post_data(order_id, detail: {})
    begin
      order_data = OrdersDatum.find_or_initialize_by(order_id: order_id)
      order_data.detail = order_data.detail.merge(detail.stringify_keys)
      order_data.save!
    rescue
      nil
    end
  end

end
