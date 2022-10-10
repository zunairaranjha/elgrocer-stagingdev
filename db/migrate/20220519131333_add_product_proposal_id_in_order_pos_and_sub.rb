class AddProductProposalIdInOrderPosAndSub < ActiveRecord::Migration[5.1]
  def change
    add_column :order_positions, :product_proposal_id, :integer
    add_column :order_substitutions, :product_proposal_id, :integer
  end
end
