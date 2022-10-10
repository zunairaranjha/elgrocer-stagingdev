module GeocoderStub
  Geocoder.configure(:lookup => :test)

  Geocoder::Lookup::Test.set_default_stub(
   [
      "data" =>
        { "address_components"=>
            [{"long_name"=>"Armada P3", "short_name"=>"Armada P3", "types"=>["premise"]},
             {"long_name"=>"Al Thanyah Fifth", "short_name"=>"Al Thanyah Fifth", "types"=>["political", "sublocality", "sublocality_level_1"]},
             {"long_name"=>"Dubai", "short_name"=>"Dubai", "types"=>["locality", "political"]},
             {"long_name"=>"Dubai", "short_name"=>"Dubai", "types"=>["administrative_area_level_1", "political"]},
             {"long_name"=>"United Arab Emirates", "short_name"=>"AE", "types"=>["country", "political"]}],
          "formatted_address"=>"Armada P3 - Dubai - United Arab Emirates",
          "geometry"=>
             {"location"=>{"lat"=>25.0754349, "lng"=>55.1452789},
              "location_type"=>"ROOFTOP",
              "viewport"=>
               {"northeast"=>{"lat"=>25.0767838802915, "lng"=>55.1466278802915}, "southwest"=>{"lat"=>25.07408591970849, "lng"=>55.1439299197085}}},
          "place_id"=>"ChIJDyhyGKlsXz4R5srKjybbi6M",
          "types"=>["street_address"]
        }
    ]
  )
  # Geocoder::Lookup::Test.set_default_stub(
  #   [
  #     {
  #       'latitude'     => 40.7143528,
  #       'longitude'    => -74.0059731,
  #       'address'      => 'New York, NY, USA',
  #       'state'        => 'New York',
  #       'state_code'   => 'NY',
  #       'country'      => 'United States',
  #       'country_code' => 'US'
  #     }
  #   ]
  # )
end
