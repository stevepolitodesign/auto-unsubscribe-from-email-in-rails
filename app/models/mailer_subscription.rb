class MailerSubscription < ApplicationRecord
  belongs_to :user

  MAILERS = OpenStruct.new(
    items: [
      {
        class: "MarketingMailer",
        name: "Marketing Emails",
        description: "Emails about promotions and sales"
      }
    ]
  ).freeze

  validates :subscribed, inclusion: [true, false], allow_nil: true
  validates :mailer, presence: true
  validates :mailer, inclusion: MAILERS.items.map{ |item|  item[:class] }
  validates :user, uniqueness: { scope: :mailer }
end