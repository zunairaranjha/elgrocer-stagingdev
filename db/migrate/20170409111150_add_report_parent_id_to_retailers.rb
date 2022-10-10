class AddReportParentIdToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :report_parent_id, :integer
  end
end
