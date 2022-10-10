class SitemapUpdate
  @queue = :sitemap_update_queue

  def self.perform
    SitemapData.refresh
    sleep(180)
    %x(bundle exec rake sitemap:refresh)
  end
end