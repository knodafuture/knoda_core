class SendGroupInvite
  include Sidekiq::Worker

  def perform(invite_id)
    ActiveRecord::Base.connection_pool.with_connection do
      invitation = Invitation.find(invite_id).send_invite()
    end
  end
end
