class AddNotifiedAtToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :notified_at, :datetime
  end
end
