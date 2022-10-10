class AddKeywordsToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :keywords, :string
    add_column :banners, :banner_type, :integer, default: 0
  end
end
