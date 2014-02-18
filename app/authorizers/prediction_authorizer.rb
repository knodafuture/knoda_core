class PredictionAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end
  
  def self.readable_by?(user)
    true
  end
  
  def updatable_by?(user)
    user.id == resource.user_id
  end
    
  def agreeable_by?(user)    
    (user.id != resource.user_id) &&
      !resource.is_expired? &&
      !resource.is_closed?
  end
  
  def disagreeable_by?(user)
    (user.id != resource.user_id) &&
      !resource.is_expired? &&
      !resource.is_closed?
  end
  
  def realizable_by?(user)
    (resource.is_expired? && !resource.is_closed?) &&
      ((resource.user_id == user.id) ||
        (((resource.resolution_date ? resource.resolution_date : resource.expires_at) + 3.days).past? &&
          !user.challenges.where(prediction_id: resource.id).empty?))
  end
  
  def unrealizable_by?(user)
    (resource.is_expired? && !resource.is_closed?) &&
      ((resource.user_id == user.id) ||
        (((resource.resolution_date ? resource.resolution_date : resource.expires_at) + 3.days).past? &&
          !user.challenges.where(prediction_id: resource.id).empty?))
  end
  
  def bsable_by?(user)
    (resource.is_expired? && resource.is_closed?) &&
      !user.challenges.where("prediction_id = ? and bs is not true", resource.id).blank?
  end

  def commentable_by?(user)
    true
  end
end