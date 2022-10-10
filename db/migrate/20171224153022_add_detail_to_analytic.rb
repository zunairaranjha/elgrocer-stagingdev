class AddDetailToAnalytic < ActiveRecord::Migration
  def change
    add_column :analytics, :detail, :string
  end
end
