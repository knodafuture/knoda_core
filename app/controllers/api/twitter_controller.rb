class Api::TwitterController < ActionController::Base
	include AuthenticationConcern

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {error: 'required parameter missing'}, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {error: 'item not found'}, status: 404
  end

	def create
		p = tweet_params

		if p[:prediction_id]
			TwitterWorker.perform_async(current_user.id,prediction_id)
		end

		head :no_content
	end

	def tweet_params
  	return params.permit(:prediction_id)
	end
end
