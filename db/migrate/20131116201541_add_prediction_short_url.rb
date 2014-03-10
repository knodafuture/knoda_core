class AddPredictionShortUrl < ActiveRecord::Migration
  def change
    add_column :predictions, :short_url, :string
  end
end
