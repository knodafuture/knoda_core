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
			FacebookWorker.perform_in(3.seconds, current_user.id,p[:prediction_id])
		end

		head :no_content
	end

	def post_params
      params.permit(:prediction_id, :group_id)
    end
end
