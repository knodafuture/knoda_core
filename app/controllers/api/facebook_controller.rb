class Api::FacebookController < ActionController::Base
	include AuthenticationConcern

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {error: 'required parameter missing'}, status: 422
  end
 
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {error: 'item not found'}, status: 404
  end

	def create
		p = post_params

		if p[:prediction_id]
			postPrediction Prediction.find(p[:prediction_id])
		end

		head :no_content
	end

	def post(url)
		account = current_user.facebook_account
		unless account
			return;
		end

		graph = Koala::Facebook::API.new(account.access_token)
		graph.put_connections("me", "knodafacebook:share", :prediction => url)  

		client.update(message)

	end

	def postPrediction(prediction)
		puts prediction.to_json
		post prediction.short_url
	end

	def post_params
      params.permit(:prediction_id, :group_id)
    end
end