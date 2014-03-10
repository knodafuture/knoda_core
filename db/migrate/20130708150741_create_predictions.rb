class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.integer :user_id
      t.string :text
      t.date :expires_at
      t.boolean :closed
      t.date :closed_at
      t.boolean :closed_as

      t.timestamps
    end
  end
end
