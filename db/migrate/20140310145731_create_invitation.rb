class CreateInvitation < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :user, :null => false
      t.integer :group_id
      t.string :code
      t.integer :recipient_user_id, :null => true
      t.string :recipient_email
      t.boolean :active
    end
  end
end
