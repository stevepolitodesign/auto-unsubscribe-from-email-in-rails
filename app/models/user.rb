class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :mailer_subscriptions, dependent: :destroy

  def subscribed_to_mailer?(mailer)
    MailerSubscription.find_by(
      user: self,
      mailer: mailer,
      subscribed: true
    ).present?
  end

end
