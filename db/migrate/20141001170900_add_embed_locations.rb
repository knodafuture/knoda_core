class AddEmbedLocations < ActiveRecord::Migration
def change
  create_table :embed_locations do |t|
    t.integer "prediction_id"
    t.integer "contest_id"
    t.text "url"
    t.integer "view_count", default: 0
    t.timestamps
  end
end
end
