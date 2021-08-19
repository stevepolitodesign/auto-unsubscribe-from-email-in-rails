class MailerSubscription < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: { scope: :mailer }
  validates :subscribed, inclusion: [true, false], allow_nil: true
end