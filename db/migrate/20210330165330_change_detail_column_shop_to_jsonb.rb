class ChangeDetailColumnShopToJsonb < ActiveRecord::Migration[5.1]
  def change
    change_column :shops, :detail, :jsonb, using: 'detail::text::jsonb'
  end
end
