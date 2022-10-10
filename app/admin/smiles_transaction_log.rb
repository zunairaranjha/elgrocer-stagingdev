# frozen_string_literal: true

ActiveAdmin.register SmilesTransactionLog do
  menu parent: "Orders"
  actions :all, except: [:destroy, :new, :edit]


  index do
    column :event
    column :transaction_id
    column :transaction_ref_id
    column :order_id
    column :shopper_id
    column :conversion_rule
    column 'total_smiles_points' do |sp|
      sp.details['request']['points_value'] || sp.details['request']['spend_value'] || sp.details['response']['smiles_points'] rescue nil
    end
    column :transaction_amount
    column :created_at
    actions
  end

  filter :event
  filter :transaction_id
  filter :transaction_ref_id
  filter :order_id
  filter :shopper_id
  filter :created_at

  show do
    attributes_table do
      row :event
      row :transaction_id
      row :transaction_ref_id
      row :order_id
      row :shopper_id
      row :conversion_rule
      row 'total_smiles_points' do |sp|
        sp.details['request']['points_value'] || sp.details['request']['spend_value'] || sp.details['response']['smiles_points'] rescue nil
      end
      row :transaction_amount
      row :created_at
    end
  end

end
