class MailerSubscription < ApplicationRecord
  belongs_to :user

  MAILERS = OpenStruct.new(
    items: [
      {
        class: "MarketingMailer",
        name: "Marketing Emails",
        description: "Updates on promotions and sales."
      },
      {
        class: "NotificationMailer",
        name: "Notification Emails",
        description: "Notifications from the website."
      }
    ]
  ).freeze

  validates :subscribed, inclusion: [true, false], allow_nil: true
  validates :mailer, presence: true
  validates :mailer, inclusion: MAILERS.items.map{ |item|  item[:class] }
  validates :user, uniqueness: { scope: :mailer }

  def details
    MailerSubscription::MAILERS.items.select {|item| item[:class] == mailer }
  end
  
  def name
    details[0][:name]
  end

  def description
    details[0][:description]
  end

  def action
    subscribed? ? "Unsubscribe from" : "Subscribe to"
  end

  def call_to_action
    "#{action} #{name}"
  end

end