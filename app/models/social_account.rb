class SocialAccount < ActiveRecord::Base
	include Authority::Abilities
	validate do |account|
		q = SocialAccount.where(:provider_name => account.provider_name, :provider_id => account.provider_id)
		if account.id
			q.where('id != ?', account.id)
		end
		if q.first()
			account.errors.add(:user_facing, "This account is already in use by another Knoda user.")
		end
	end
	self.authorizer_name = 'SocialAccountAuthorizer'
	belongs_to :user
end
