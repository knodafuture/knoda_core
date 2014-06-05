class CreateUserEvents < ActiveRecord::Migration
  def change
    create_table :user_events do |t|
      t.integer :user_id
      t.string :name, :null => false
      t.string :platform
      t.timestamps
    end
  end
end
