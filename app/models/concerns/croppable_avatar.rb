module CroppableAvatar extend ActiveSupport::Concern
  included do
    has_attached_file :avatar, :styles => { :big => "344х344>", :small => "100x100>"}
  end

  module ClassMethods
  end
end  
