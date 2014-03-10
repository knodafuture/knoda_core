class AddActivity < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.integer :prediction_id
      t.text :body
      t.string :activity_type
      t.timestamps
    end
    add_index :activities, :user_id
  end
end
