class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, :null => false, :default => ""
      t.string :description, :null => true
      t.integer :owner_id
      t.string :share_url
      t.timestamps
    end
    add_attachment :groups, :avatar
    create_table :memberships do |t|
      t.references :user, :null => false
      t.references :group, :null => false
      t.string :role, :null => false, :default => 'MEMBER'
    end
    add_index(:memberships, [:user_id, :group_id], :unique => true)
  end
end
