class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    @mailer_subscription = MailerSubscription.find_or_initialize_by(
      user: @user,
      mailer: params[:mailer]
    )
    @mailer_subscription.subscribed = false
    if @mailer_subscription.save
      @message = "You've successfully unsubscribed from this email."
    else
      @message = "There was an error"
    end
  end

  private

    def set_user
      @user = GlobalID::Locator.locate_signed params[:id]
      @message =  "There was an error" if @user.nil?
    end

end
