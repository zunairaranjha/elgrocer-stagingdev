class AddSubstituteDetailToOrderSubstitutions < ActiveRecord::Migration
  def change
    add_column :order_substitutions, :substitute_detail, :json
  end
end
