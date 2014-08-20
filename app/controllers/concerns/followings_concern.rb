module FollowingsConcern extend ActiveSupport::Concern
  def create
    if params[:leader_id]
      @following = current_user.followings.build(:leader_id => params[:leader_id])
      if @following.save
        render :json => @following, :status => 201
      else
        render :json => @following.errors, :status => 500
      end
    else
      @followings = []
      params[:_json].each do | following_list_params |
        following_list_params.permit!
        following = current_user.followings.create!(following_list_params)
        @followings << following
      end
      render :json => @followings, :status => 201, root: false
    end
  end

  def destroy
    @following = current_user.followings.find(params[:id])
    @following.destroy
    head :no_content
  end
end
