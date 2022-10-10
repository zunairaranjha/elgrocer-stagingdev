class Shoppers::UpdateInvoiceAddress < Shoppers::Base

  integer :shopper_id
  string :invoice_city, default: nil
  string :invoice_street, default: nil
  string :invoice_building_name, default: nil
  string :invoice_apartment_number, default: nil
  integer :invoice_floor_number, default: nil
  integer :invoice_location_id, default: nil

  validate :shopper_exists

  def execute
    update_shopper_invoice_addresses!
  end

  private

  def shopper
    @shopper ||= Shopper.find(shopper_id)
  end

  def update_shopper_invoice_addresses!
    shopper.update!(new_params)
    shopper
  end

  def new_params
    params = {
       invoice_city: invoice_city,
       invoice_street: invoice_street,
       invoice_building_name: invoice_building_name,
       invoice_apartment_number: invoice_apartment_number,
       invoice_floor_number: invoice_floor_number,
       invoice_location_id: invoice_location_id
    }
    params
  end

end
