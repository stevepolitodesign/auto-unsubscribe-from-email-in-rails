class MailerSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @mailer_subscriptions = MailerSubscription::MAILERS.items.map do |item|
      MailerSubscription.find_or_initialize_by(mailer: item[:class], user: current_user)
    end
  end

  def create
  end

  def update
    @mailer_subscription.toggle!(:subscribed)
  end
end
