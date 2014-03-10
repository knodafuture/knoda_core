class CreateAndroidDeviceTokens < ActiveRecord::Migration
  def change
    create_table :android_device_tokens do |t|
      t.integer :user_id
      t.string :token

      t.timestamps      
    end
    add_index :android_device_tokens, [:user_id, :token], :unique => true
  end
end