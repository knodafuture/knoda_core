class AddTitleToPrediction < ActiveRecord::Migration
  def change
    add_column :predictions, :title, :string
  end
end
