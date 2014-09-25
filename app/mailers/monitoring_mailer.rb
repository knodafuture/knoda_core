class MonitoringMailer < ActionMailer::Base
  require 'mail'
  address = Mail::Address.new "support@knoda.com"
  address.display_name = "Knoda"
  default from: address.format

  def retryQueue
    @level = Rails.application.config.knoda_web_url
    mail to: 'aengland@knoda.com'
  end
end
