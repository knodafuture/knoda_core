class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.text :tag
      t.integer :used, default: 0
      t.timestamps
    end
  end
end
