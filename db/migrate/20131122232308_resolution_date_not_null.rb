class ResolutionDateNotNull < ActiveRecord::Migration
  def change
    change_column :predictions, :resolution_date, :datetime, :null => false
  end
end
