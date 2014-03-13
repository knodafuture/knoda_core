class SignupMailer < MandrillMailer::TemplateMailer
  default from: 'support@knoda.com'

  def signup(user)
    mandrill_mail template: 'Signup',
      to: {email: user.email},
      vars: {
        'USERNAME' => user.username,
      },
      important: true,
      inline_css: true
  end
end