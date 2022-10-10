class Retailers::UpdateProfile < Retailers::Base
  integer :retailer_id
  string :email, default: nil
  string :company_name
  string :phone_number
  string :company_address
  integer :location_id, default: nil
  string :street, default: nil
  string :building, default: nil
  string :apartment, default: nil
  string :flat_number, default: nil
  string :contact_email
  string :contact_person_name, default: nil
  string :opening_time
  integer :delivery_range
  float :latitude
  float :longitude
  file :photo, default: nil

  validate :retailer_exists

  def execute
    update_profile!
    retailer.reload
  end

  private

  def retailer
    @retailer ||= Retailer.find_by({id: retailer_id})
  end

  def update_params
    params = {
      company_name: company_name,
      email: email,
      contact_email: contact_email,
      phone_number: phone_number,
      company_address: company_address,
      street: street,
      building: building,
      apartment: apartment,
      flat_number: flat_number,
      contact_person_name: contact_person_name,
      opening_time: opening_time,
      delivery_range: delivery_range,
      latitude: latitude,
      longitude: longitude }
    params[:location_id] = location_id if location_id.present?
    params[:photo] = photo if photo.present?
    params.compact
  end

  def update_profile!
    retailer.update!(update_params)
    retailer.convert_opening_time
    retailer
  end
end
