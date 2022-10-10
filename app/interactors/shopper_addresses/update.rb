class ShopperAddresses::Update < ShopperAddresses::Base
  integer :shopper_id
  integer :address_id
  integer :address_type_id, default: nil
  string :address_name, default: nil
  string :street, default: nil
  string :building_name, default: nil
  string :apartment_number, default: nil
  float :longitude, default: nil
  float :latitude, default: nil
  string :location_address, default: nil
  boolean :default_address, default: nil
  string :additional_direction, default: nil
  string :floor, default: nil
  string :house_number, default: nil
  string :area, default: nil
  string :phone_number, default: nil
  string :shopper_name, default: nil
  integer :address_tag_id, default: nil
  string :date_time_offset, default: nil

  validate :shopper_exists
  validate :shopper_address_exists

  def execute
    update_shopper_addresses!
  end

  private

  def shopper_address
    @shopper_address ||= ShopperAddress.find(address_id)
  end

  def update_shopper_addresses!
    shopper_address.update!(new_params)
    shopper_address
  end

  def new_params
    params = {
       shopper_id: shopper_id,
       address_name: address_name,
       street: street,
       building_name: building_name,
       apartment_number: apartment_number,
       location_address: location_address,
       default_address: default_address,
       address_type_id: address_type_id,
       additional_direction: additional_direction,
       floor: floor,
       house_number: house_number,
       area: area,
       phone_number: phone_number,
       shopper_name: shopper_name,
       address_tag_id: address_tag_id,
       date_time_offset: date_time_offset
    }
    params.merge!(lonlat: "POINT (#{longitude} #{latitude})") if lonlat?
    params.compact
  end

  def lonlat?
    longitude.present? && latitude.present?
  end
end
