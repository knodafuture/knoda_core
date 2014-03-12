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

    create_table :invitations do |t|
      t.references :user, :null => false
      t.integer :group_id
      t.string :code
      t.integer :recipient_user_id
      t.string :recipient_email
      t.string :recipient_phone
      t.boolean :accepted
      t.datetime :notified_at
      t.timestamps
    end    

    add_column :predictions, :group_id, :integer
  end
end
