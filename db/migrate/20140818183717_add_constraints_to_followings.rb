class AddConstraintsToFollowings < ActiveRecord::Migration
  def change
    change_column :followings, :user_id, :integer, :null => false
    change_column :followings, :leader_id, :integer, :null => false
  end
end
