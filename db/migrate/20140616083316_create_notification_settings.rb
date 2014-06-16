class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
      t.integer :user_id
      t.string :setting, :null => false
      t.boolean :active, :default => true
      t.timestamps
    end
  end
end
