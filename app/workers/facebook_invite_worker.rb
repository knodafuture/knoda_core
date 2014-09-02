class FacebookInviteWorker
  include Sidekiq::Worker
  @queue = :facebook

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.facebook_account
      unless account
        return;
      end

      graph = Koala::Facebook::API.new(account.access_token)
      @graph.put_connections("me", "feed", :message => "I'm on Knoda.  Start following me to see all of my predictions.", :link => "#{Rails.application.config.knoda_web_url}")
    end
  end
end
