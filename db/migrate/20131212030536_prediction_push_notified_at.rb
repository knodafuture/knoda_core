class PredictionPushNotifiedAt < ActiveRecord::Migration
  def change
    rename_column :predictions, :notified_at, :push_notified_at
    add_column :predictions, :activity_sent_at, :datetime
  end
end
