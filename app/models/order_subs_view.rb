class OrderSubsView < OrderSubstitution

  self.table_name = "order_substitutions_view"

  def readonly?
    true
  end
  # belongs_to :order_positions_view, foreign_key: 'order_product', primary_key: 'order_product'

end

