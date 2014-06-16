class NotificationSetting < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'NotificationSettingAuthorizer'  
  belongs_to :user, inverse_of: :notification_settings
end
