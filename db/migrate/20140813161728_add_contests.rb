class AddContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.string :name, :null => false, :default => ""
      t.string :description, :null => true
      t.string :detail_url
      t.string :rules_url
      t.integer :owner_id
      t.timestamps
    end

    create_table :contest_stages do |t|
      t.string :name, :null => false
      t.integer :contest_id
      t.integer :sort_order
    end

    add_attachment :contests, :avatar
    add_column :predictions, :contest_id, :integer
    add_column :predictions, :contest_stage_id, :integer
    add_index :predictions, :contest_id
    add_index :predictions, :contest_stage_id
  end

end
