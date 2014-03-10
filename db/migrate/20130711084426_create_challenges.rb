class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.integer :user_id
      t.integer :prediction_id
      t.boolean :is_positive

      t.timestamps

    end

    add_index :challenges, :user_id
    add_index :challenges, :prediction_id
    add_index :challenges, [:user_id, :prediction_id], unique: true
  end


end
