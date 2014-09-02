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
		if params[:type] == 'brag'
			brag = true
		else
			brag = false
		end
		if p[:prediction_id]
			TwitterWorker.perform_in(5.seconds, current_user.id, p[:prediction_id], brag)
		else
			if p[:message]
				TwitterInviteWorker.perform_async(current_user.id, p[:message])
			else
				TwitterInviteWorker.perform_async(current_user.id)
			end
		end
		head :no_content
	end

	def tweet_params
  	return params.permit(:prediction_id, :message)
	end
end
