class UserAgreement < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_agreements
end
