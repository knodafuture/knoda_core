class UserWelcomeEmail
  include Sidekiq::Worker

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      SignupMailer.signup(User.find(user_id)).deliver
    end
  end
end
