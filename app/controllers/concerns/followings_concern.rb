module FollowingsConcern extend ActiveSupport::Concern
  def create
    @following = current_user.followings.build(:leader_id => params[:leader_id])
    if @following.save
      render :json => @following, :status => 201
    else
      render :json => @following.errors, :status => 500
    end
  end

  def destroy
    @following = current_user.followings.find(params[:id])
    @following.destroy
    head :no_content
  end
end
