class AddImageToPrediction < ActiveRecord::Migration
def self.up
  add_attachment :predictions, :shareable_image
end

def self.down
  remove_attachment :predictions, :shareable_image
end
end
