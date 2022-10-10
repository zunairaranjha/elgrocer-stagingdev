class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, null: false
      t.timestamps
    end

    change_table :locations do |t|
      t.belongs_to :city, index: true
    end

    add_foreign_key :locations, :cities, column: :city_id

    Rake::Task['locations:set_city'].invoke
  end
end
