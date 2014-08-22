module DeviseConcern extend ActiveSupport::Concern
  included do
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :trackable, :validatable,
           :token_authenticatable, :omniauthable,
           :authentication_keys => [:login]
  end
end
