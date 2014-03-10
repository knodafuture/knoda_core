class AddVerifiedToUser < ActiveRecord::Migration
  def change
  	add_column :users, :verified_account, :boolean, :default => false
  end
end
