class AddIsClosedToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :is_closed, :boolean, :default => false
  end
end
