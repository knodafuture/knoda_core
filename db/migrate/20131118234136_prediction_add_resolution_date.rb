class PredictionAddResolutionDate < ActiveRecord::Migration
  def change
    add_column :predictions, :resolution_date, :datetime, :default => nil
  end
end
