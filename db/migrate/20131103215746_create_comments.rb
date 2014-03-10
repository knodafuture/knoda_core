class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :prediction_id
      t.string :text
      t.boolean :seen, :default => false
      t.timestamps
    end
  end
end