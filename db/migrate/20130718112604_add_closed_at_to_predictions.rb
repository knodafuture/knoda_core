class AddClosedAtToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :closed_at, :datetime
  end
end
