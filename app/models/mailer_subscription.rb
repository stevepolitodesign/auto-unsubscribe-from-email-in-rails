class MailerSubscription < ApplicationRecord
  belongs_to :user

  MAILERS = %w(MarketingMailer)

  validates :subscribed, inclusion: [true, false], allow_nil: true
  validates :mailer, presence: true
  validates :mailer, inclusion: MAILERS
  validates :user, uniqueness: { scope: :mailer }
end