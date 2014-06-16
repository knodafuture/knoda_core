class AddGuestmodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guest_mode, :boolean, :default => false
  end
end
