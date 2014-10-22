class MarketingPush
  include Sidekiq::Worker

  def perform(params)
    ActiveRecord::Base.connection_pool.with_connection do
      puts "hello marketing push"
      puts params['userinput']
      message = params['bodyinput']
      title = params['titleinput']

      #if one user

      #if contest

      #if platform

    end
  end
end
