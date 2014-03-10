class AddAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean
    add_column :users, :username, :string
    add_column :users, :notifications, :boolean
  end
end
