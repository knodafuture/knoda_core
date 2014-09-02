module FollowingsConcern extend ActiveSupport::Concern

  def index
    if params[:mode] == 'as_follower'
      @followings = current_user.followings
    elsif params[:mode] == 'as_leader'
      @followings = current_user.inverse_followings
    else
      @followings = Following.where('user_id = ? OR leader_id = ?', current_user.id, current_user.id)
    end
    render :json => @followings, root: false
  end

  def create
    if params[:leader_id]
      @following = Following.find_or_initialize_by(:leader_id => params[:leader_id], :user_id => current_user.id)
      if @following.save
        render :json => @following, :status => 201
      else
        render :json => @following.errors, :status => 500
      end
    else
      @followings = []
      params[:_json].each do | following_list_params |
        following_list_params.permit!
        begin
          following = current_user.followings.create!(following_list_params)
          @followings << following
        rescue ActiveRecord::RecordNotUnique => e
        end
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
