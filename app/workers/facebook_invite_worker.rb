class FacebookInviteWorker
  include Sidekiq::Worker

  def perform(user_id, msg=nil)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.facebook_account
      unless account
        return;
      end

      graph = Koala::Facebook::API.new(account.access_token)
      if msg
        message = msg
      else
        message = "I'm on Knoda. Start following me to see all of my predictions."
      end
      graph.put_connections("me", "feed", :message => message, :link => "#{Rails.application.config.knoda_web_url}")
    end
  end
end
