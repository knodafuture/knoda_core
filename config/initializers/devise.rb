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


module Devise
  module Models
    # Track information about your user sign in. It tracks the following columns:
    #
    # * sign_in_count      - Increased every time a sign in is made (by form, openid, oauth)
    # * current_sign_in_at - A timestamp updated when the user signs in
    # * last_sign_in_at    - Holds the timestamp of the previous sign in
    # * current_sign_in_ip - The remote ip updated when the user sign in
    # * last_sign_in_ip    - Holds the remote ip of the previous sign in
    #
    module Trackable
      def self.required_fields(klass)
        [:current_sign_in_at, :current_sign_in_ip, :last_sign_in_at, :last_sign_in_ip, :sign_in_count, :last_api_version]
      end

      def update_tracked_fields(request)
        old_current, new_current = self.current_sign_in_at, Time.now.utc
        self.last_sign_in_at     = old_current || new_current
        self.current_sign_in_at  = new_current

        old_current, new_current = self.current_sign_in_ip, request.remote_ip
        self.last_sign_in_ip     = old_current || new_current
        self.current_sign_in_ip  = new_current

        self.sign_in_count ||= 0
        self.sign_in_count += 1

        begin
          self.last_api_version = VersionCake::VersionedRequest.new(request, nil).version
        rescue
        end
      end

      def update_tracked_fields!(request)
        update_tracked_fields(request)
        save(validate: false) or raise "Devise trackable could not save #{inspect}." \
          "Please make sure a model using trackable can be saved at sign in."
      end
    end
  end
end
