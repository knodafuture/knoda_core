class GroupsIndices < ActiveRecord::Migration
  def change
    add_index :predictions, :group_id
    add_index :memberships, :user_id
    add_index :memberships, [:group_id, :user_id, :role]
    add_index :groups, :share_id
  end
end
