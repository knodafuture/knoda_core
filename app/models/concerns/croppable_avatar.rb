module CroppableAvatar extend ActiveSupport::Concern
  included do
    has_attached_file :avatar, :styles => { :big => "344х344>", :small => "100x100>"}, :default_url => ""
  end

  module ClassMethods
  end

  def avatar_from_path(path)
    self.avatar = File.open(path)
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
