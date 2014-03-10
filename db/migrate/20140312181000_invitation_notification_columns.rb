class InvitationNotificationColumns < ActiveRecord::Migration
  def change
    rename_column :invitations, :active, :accepted
    add_column :invitations, :push_notified_at, :datetime
    add_column :invitations, :email_notified_at, :datetime
  end
end
