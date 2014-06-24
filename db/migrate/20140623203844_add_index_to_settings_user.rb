class AddIndexToSettingsUser < ActiveRecord::Migration
  def change
    add_index :notification_settings, :user_id
  end
end
