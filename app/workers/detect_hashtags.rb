class DetectHashtags
  include Sidekiq::Worker

  def perform(text)
    ActiveRecord::Base.connection_pool.with_connection do
      tags = text.scan(/#(\w+)/).flatten
      tags.each do |t|
        ht = Hashtag.where(:tag => t).first_or_initialize
        ht.used = ht.used + 1
        ht.save
      end
    end
  end
end
