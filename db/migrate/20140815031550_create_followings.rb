class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer "user_id"
      t.integer "leader_id"
    end
    add_index "followings", ["user_id", "leader_id"], :name => "index_followers_on_user_id_and_leader_id", :unique => true
  end
end
