class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :leader, :class_name => "User"
end
