class AddShortUrl < ActiveRecord::Migration
  def change
    create_table :short_urls do |t|
      t.string :slug
      t.string :long_url
    end
  end
end
