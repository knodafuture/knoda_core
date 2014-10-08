module HashtagsConcern extend ActiveSupport::Concern
  def autocomplete
    if params[:q]
      tags = Hashtag.select(:tag).where('tag ilike ?', params[:q] + '%').order('used desc').limit(10)
      render :json => tags.pluck(:tag), :root => false
    else
      render :json => [], :root => false
    end
  end
end
