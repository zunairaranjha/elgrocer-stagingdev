class CreateShopRetailerView < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE VIEW public.shop_join_retailer
            AS
            SELECT s.id,
                   s.retailer_id,
                   s.product_id,
                   round(s.price_dollars::numeric + s.price_cents::numeric / 100.0, 2) AS full_price,
                   s.price_currency,
                   s.product_rank,
                   s.is_published,
                   s.is_available,
                   s.is_promotional,
                   s.detail,
                   s.promotion_only,
                   s.available_for_sale,
                   r.with_stock_level,
                   r.slug,
                   s.created_at,
                   s.updated_at
            FROM shops s
                     JOIN retailers r ON s.retailer_id = r.id
            WHERE s.retailer_id = r.id;
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP VIEW IF EXISTS public.shop_join_retailer;
        SQL
      end
    end
  end
end
