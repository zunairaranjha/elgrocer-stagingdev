class CreateProductProposalCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :product_proposal_categories do |t|
      t.integer :product_proposal_id
      t.integer :category_id

      t.timestamps
    end
  end
end
