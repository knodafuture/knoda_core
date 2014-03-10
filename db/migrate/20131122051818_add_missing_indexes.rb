class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :comments, :user_id
    add_index :comments, :prediction_id
    add_index :predictions, :user_id
    add_index :badges, :user_id
  end
end