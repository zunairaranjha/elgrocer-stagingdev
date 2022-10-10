require 'ostruct'

module Scraper
  class Supermart < Base
    def initialize
      super("http://supermart.ae/")
    end

    def scrape!(max = nil)
      i = 0
      categories_urls.each do |category|
        current_page = category
        loop do 
          ps = products(current_page) rescue []
          ps.each do |product_page|
            obj = to_object(product_page) rescue nil
            yield obj if obj
            return if max and i >= max
            i += 1
          end
          current_page = next_page(current_page)
          break unless current_page 
        end
      end
    end

    private

      def categories_urls
        mechanize.get(@url) do |page|
          return page.search("#SideCategoryList .sf-menu > li > a").map{|a| a.attr("href")}
        end
      end

      def next_page page_url
        mechanize.get(page_url) do |page|
          current_element = page.search(".CategoryPagination .PagingList li.ActivePage").first()
          return nil unless current_element
          next_element = current_element.next()
          return nil if !next_element || next_element.name != "li"
          return next_element.search("a").first.attr("href")
        end
      end

      def products page_url
        mechanize.get(page_url) do |page|
          list = page.search(".Content .ProductList li .ProductDetails a")
          return list.map{|a| a.attr("href")}
        end
      end

      def to_object (product_page_url)
        mechanize.get(product_page_url) do |page|
          p = Scraper::Model.new
          p.url = product_page_url
          p.name = page.search(".PrimaryProductDetails h2").text.strip
          page.search(".ProductDetailsGrid .DetailRow").each do |d|
            case d.search(".Label").text.strip
            when /Price/
              p.price = d.search(".Value").text.strip
            when /Brand/
              p.brand = d.search(".Value").text.strip
            when /Weight/
              p.weights = d.search(".Value ul li label").map{|a| a.text.strip} 
            end
          end
          p.img_url = page.search(".ProductThumbImage a").first().attr("href")
          p.description = page.search(".ProductDescriptionContainer").text.strip
          page.search(".FindByCategory ul").each do |ul|
            p.categories ||= []
            p.categories.push ul.search("li a").map{|a| a.text.strip}
          end
          return p
        end
      end
  end
end