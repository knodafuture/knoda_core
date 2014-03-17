class AddInvitationsToActivites < ActiveRecord::Migration
  def change
    add_column :activities, :invitation_code, :text
    add_column :activities, :invitation_sender, :text
    add_column :activities, :invitation_group_name, :text
  end
end