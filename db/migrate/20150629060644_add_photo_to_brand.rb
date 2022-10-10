class AddPhotoToBrand < ActiveRecord::Migration
  def change
    add_attachment :brands, :photo
    add_column :brands, :group_name, :string
  end
end
