class AddShareIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :share_id, :string
  end
end
