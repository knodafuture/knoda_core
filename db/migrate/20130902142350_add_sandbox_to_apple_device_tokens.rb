class AddSandboxToAppleDeviceTokens < ActiveRecord::Migration
  def change
    add_column :apple_device_tokens, :sandbox, :boolean, :default => false
  end
end
