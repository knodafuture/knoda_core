class FindRivals
  include Sidekiq::Worker
  @queue = :rivals

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      if user
        Rails.cache.write("user_#{user.id}_rivals", user.find_rivals)
      end
    end
  end
end
