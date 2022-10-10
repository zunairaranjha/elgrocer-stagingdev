class AddFeedbackDurationToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :feedback_duration, :string
  end
end
