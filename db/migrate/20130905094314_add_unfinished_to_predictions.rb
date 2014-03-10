class AddUnfinishedToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :unfinished, :datetime, :default => nil
  end
end
