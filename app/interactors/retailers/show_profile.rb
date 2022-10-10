class Retailers::ShowProfile < Retailers::Base
  integer :retailer_id
  
  validate :retailer_exists
  
  def execute
    retailer
  end
  
  private
  
  def retailer
    @retailer ||= Retailer.find_by(id: retailer_id)
  end
  
end