module CroppableAvatar extend ActiveSupport::Concern
  included do
    has_attached_file :avatar, :styles => { :big => "344х344>", :small => "100x100>"}
  end

  module ClassMethods
  end
  
  def avatar_image
    if self.avatar.exists?
      {
        big: self.avatar(:big),
        small: self.avatar(:small)
      }
    else
      nil
    end
  end  
end  
