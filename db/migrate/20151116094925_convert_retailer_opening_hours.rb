class ConvertRetailerOpeningHours < ActiveRecord::Migration
  def change
  	Retailer.all.each{|retailer|
      if !retailer.opening_time.blank?
    		json = JSON.parse(retailer.opening_time)
    		
    		#PARSING JSON
    		week_days_opening = json["opening_hours"][0]#week days
    		week_days_closing = json["closing_hours"][0]
    		thursday_opening = json["opening_hours"][1]#thursday
    		thursday_closing = json["closing_hours"][1]
    		friday_opening = json["opening_hours"][2]#friday
    		friday_closing = json["closing_hours"][2]
    		##################

    		[1,2,3,4,7].each{|day| # WEEK STARTING FROM SUNDAY
          opening_hour = RetailerOpeningHour.new
    			opening_hour.day = day
    			opening_hour.open = week_days_opening
    			opening_hour.close = week_days_closing
          retailer.retailer_opening_hours << opening_hour
          opening_hour.save!
    		}

        opening_hour = RetailerOpeningHour.new
    		opening_hour.day = 5
    		opening_hour.open = thursday_opening
    		opening_hour.close = thursday_closing
        retailer.retailer_opening_hours << opening_hour
        opening_hour.save!

        opening_hour = RetailerOpeningHour.new
    		opening_hour.day = 6
    		opening_hour.open = friday_opening
    		opening_hour.close = friday_closing
    		retailer.retailer_opening_hours << opening_hour
        opening_hour.save!
      end
  	}
  end
end
