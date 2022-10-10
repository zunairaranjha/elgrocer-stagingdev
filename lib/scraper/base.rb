require 'mechanize'

module Scraper
  class Base

    def initialize(url)
      @url = url
    end

    def mechanize
      @m ||= Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
    end

    def scrape!
      throw "you have to implement this method"
    end
  end
end