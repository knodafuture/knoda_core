class EmbedLocation < ActiveRecord::Base
  belongs_to :contest, inverse_of: :embed_locations
  belongs_to :prediction, inverse_of: :embed_locations
  before_save :increment_view_count

  validates :url, presence: true

  def increment_view_count
    self.view_count = self.view_count + 1
  end

  def domain
    URI.parse(self.url).host
  end
end
