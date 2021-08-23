class MailerSubscriptionsController < ApplicationController
  
  def create
  end

  def update
    @mailer_subscription.toggle!(:subscribed)
  end
end
