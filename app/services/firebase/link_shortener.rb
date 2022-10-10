class Firebase::LinkShortener

  def initialize
    @key = ENV['FIREBASE_LINK_SHORT_KEY']
    @base_url = ENV['FIREBASE_LINK_SHORT_URL']
    @client = HTTPClient.new
  end

  def order_short_link(order_id,shopper_id)
    body = {
        "longDynamicLink": "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forder%2Fsubstitution%3Fuser_id%3D#{shopper_id}%26order_id%3D#{order_id}%26substituteOrderID%3D#{order_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    }

    response = @client.post @base_url + "?key=#{@key}", body
    response = JSON(response.body)
    response['shortLink']
  end

  def order_pending_collection_link(order_id,shopper_id)
    body = {
      "longDynamicLink": "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fshopper_id%3D#{shopper_id}%26order_id%3D#{order_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    }

    response = @client.post @base_url + "?key=#{@key}", body
    response = JSON(response.body)
    response['shortLink']
  end

  def order_pending_payment_link(order_id,shopper_id,retailer_id)
    body = {
        "longDynamicLink": "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fuser_id%3D#{shopper_id}%26order_id%3D#{order_id}%26orderID%3D#{order_id}%26retailer_id%3D#{retailer_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    }

    response = @client.post @base_url + "?key=#{@key}", body
    response = JSON(response.body)
    response['shortLink']
  end

  def recipe_deep_link(recipe_id)
    body = {
        "longDynamicLink": "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Fcooking-recipes%2f#{recipe_id}%3FrecipeID%3D#{recipe_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    }

    response = @client.post @base_url + "?key=#{@key}", body
    response = JSON(response.body)
    response['shortLink']
    end

  def chef_deep_link(chef_id)
    body = {
        "longDynamicLink": "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Fcooking-recipes%2Fchef%2F#{chef_id}%3FchefID%3D#{chef_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    }

    response = @client.post @base_url + "?key=#{@key}", body
    response = JSON(response.body)
    response['shortLink']
  end

end

