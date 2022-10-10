class ShopperAddresses::Create < ShopperAddresses::Base
  integer :shopper_id
  string :address_name, default: nil
  integer :address_type_id, default: nil
  string :street, default: nil
  string :building_name, default: nil
  string :apartment_number, default: nil
  float  :longitude
  float  :latitude
  string :location_address
  boolean :default_address, default: false
  string :additional_direction, default: nil
  string :floor, default: nil
  string :house_number, default: nil
  string :area, default: nil
  string :phone_number, default: nil
  string :shopper_name, default: nil
  integer :address_tag_id, default: nil
  string :date_time_offset, default: nil

  validate :shopper_exists

  def execute
    create_shopper_addresses!
  end

  private

  def create_shopper_addresses!
    values = new_params
    values[:date_time_offset] = date_time_offset unless date_time_offset.blank?
    ShopperAddress.create!(values)
  end

  def new_params
    {
      shopper_id: shopper_id,
      address_name: address_name,
      street: street,
      building_name: building_name,
      apartment_number: apartment_number,
      location_address: location_address,
      lonlat: "POINT (#{longitude} #{latitude})",
      default_address: default_address,
      address_type_id: address_type_id,
      additional_direction: additional_direction,
      floor: floor,
      house_number: house_number,
      area: area,
      phone_number: shopper_phone,
      shopper_name: address_shopper_name,
      address_tag_id: address_tag_id
    }
  end

  def shopper
    @shopper ||= Shopper.find(shopper_id)
  end

  def address_shopper_name
    shopper_name.blank? ? shopper.name : shopper_name
  end

  def shopper_phone
    phone_number.blank? ? shopper.phone_number : phone_number
  end
end
