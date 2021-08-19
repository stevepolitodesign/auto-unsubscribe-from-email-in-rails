class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user

  def create
    @mailer_subscription = MailerSubscription.find_or_initialize_by(
      user: @user,
      mailer: params[:mailer]
    )
    @mailer_subscription.subscribed = false
    if @mailer_subscription.save
      render plain: "You've successfully unsubscribed from this email."
    else
      render plain: "There was an error"
    end
  end

  private

    def set_user
      @user = GlobalID::Locator.locate_signed params[:user]
      render plain: "There was an error" if @user.nil?
    end

end
