# frozen_string_literal: true

class OrderPositionsView < OrderPosition
  self.table_name = 'order_positions_view'

  has_many :order_subs_view, foreign_key: 'order_product', primary_key: 'order_product'

  def readonly?
    true
  end
end
