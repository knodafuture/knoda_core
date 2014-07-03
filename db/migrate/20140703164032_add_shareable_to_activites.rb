class AddShareableToActivites < ActiveRecord::Migration
  def change
    add_column :activities, :shareable, :boolean, :default => true
  end
end
