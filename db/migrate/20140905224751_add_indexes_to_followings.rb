class AddIndexesToFollowings < ActiveRecord::Migration
  def change
    add_index :followings, :user_id
    add_index :followings, :leader_id
  end
end
