Devise.setup do |config|
  require 'mail'
  address = Mail::Address.new "support@knoda.com"
  address.display_name = "Knoda"
  config.mailer_sender = address.format
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email, :username ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 6..20
  config.email_regexp = /\A[a-z0-9_][+a-z0-9\.\_\-]*@[a-z0-9\.\_\-]+\.[a-z0-9]+\z/i
  config.reset_password_within = 6.hours
  config.token_authentication_key = :auth_token
  config.navigational_formats = ["*/*", :html, :json]
  config.sign_out_via = :delete
end
