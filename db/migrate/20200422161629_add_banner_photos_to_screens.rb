class AddBannerPhotosToScreens < ActiveRecord::Migration
  def change
    add_attachment :screens, :banner_photo
    add_attachment :screens, :banner_photo_ar
  end
end
