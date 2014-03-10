class RemoveColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :won
    remove_column :users, :lost
  end
end
