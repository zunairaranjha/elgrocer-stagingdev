class AddPhoto1ToRetailer < ActiveRecord::Migration
  def change
    add_attachment :retailers, :photo1
  end
end
