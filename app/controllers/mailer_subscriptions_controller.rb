class MailerSubscriptionsController < ApplicationController
  def update
    @mailer_subscription.toggle!(:subscribed)
  end
end
