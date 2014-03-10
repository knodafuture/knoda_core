class AddWonAndLostToUsers < ActiveRecord::Migration
  def change
    add_column :users, :won, :integer, :default => 0
    add_column :users, :lost, :integer, :default => 0
  end
end
