class Api::TwitterController < ActionController::Base
	include AuthenticationConcern

	def create
		p = tweet_params

		if p[:prediction_id]
			tweetPrediction Prediction.find(p[:prediction_id])
		end

		head :no_content
	end

	def tweet(message)
		account = current_user.twitter_account
		unless account
			return;
		end

		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = Rails.application.config.twitter_key
			config.consumer_secret     = Rails.application.config.twitter_secret
			config.access_token        = account.access_token
			config.access_token_secret = account.access_token_secret
		end

		client.update(message)

	end

	def tweetPrediction(prediction)
		puts prediction.to_json
		message = "Check out my prediction on @KNODAfuture " + prediction.short_url
		tweet message
	end
	def tweet_params
      params.permit(:prediction_id, :group_id)
    end
end