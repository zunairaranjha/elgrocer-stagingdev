# frozen_string_literal: true

namespace :uc_shops do
  desc 'This job will unavailable the UC shops which are not getting updates'
  task availability: :environment do
    shops = Shop.joins(:product_categories).where("(LENGTH(products.barcode) < 13 AND (product_categories.category_id in (142,174,778,839) and date(detail ->>'lrd') < CURRENT_DATE - interval '1 day') OR
         (product_categories.category_id in (388) and date(detail ->>'lrd') < CURRENT_DATE))")
    product_ids = shops.distinct.pluck(:product_id)
    shops.update_all("is_available = 'f', updated_at = '#{Time.now}', detail = detail::jsonb || '{\"owner_type\": \"UC Shop Availability Scheduler\",\"owner_id\": \"0\"}'::jsonb")
    unless product_ids.blank?
      product_ids.each_slice(1000) do |pro_ids|
        AlgoliaProductIndexingJob.perform_later(pro_ids)
      end
    end
  end
end
