class AddLastApiVersionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_api_version, :integer, :null => true
  end
end
