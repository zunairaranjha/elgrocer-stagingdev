class SitemapData < ActiveRecord::Base
  self.table_name = "sitemap_data_mv"

  self.primary_key = 'id'

  def readonly?
    true
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("SET TIME ZONE '#{ENV['TZ']}';REFRESH MATERIALIZED VIEW sitemap_data_mv;")
  end
end