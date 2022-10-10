class AddPromotionalMinStockToPartnerIntegrations < ActiveRecord::Migration
  def change
    add_column :partner_integrations, :promotional_min_stock, :integer, default: 0
  end
end
