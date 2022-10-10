class AddPhotoToRetailers < ActiveRecord::Migration
  def change
    add_attachment :retailers, :photo
  end
end
