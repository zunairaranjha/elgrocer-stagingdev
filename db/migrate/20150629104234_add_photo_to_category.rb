class AddPhotoToCategory < ActiveRecord::Migration
  def change
    add_attachment :categories, :photo
  end
end
