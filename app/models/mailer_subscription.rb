class MailerSubscription < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: { scope: :mailer }
end