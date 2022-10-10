class Shoppers::ShowProfile < Shoppers::Base
  integer :shopper_id

  validate :shopper_exists

  def execute
    shopper
  end

  private

  def shopper
    @shopper ||= Shopper.find_by(id: shopper_id)
  end
end
