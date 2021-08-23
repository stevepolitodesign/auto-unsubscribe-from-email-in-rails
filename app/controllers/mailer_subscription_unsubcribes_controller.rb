class MailerSubscriptionUnsubcribesController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :set_mailer_subscription, only: [:show, :update]

  def show
    @mailer_subscription.subscribed = false
    if @mailer_subscription.save
      @message = "You've successfully unsubscribed from this email."
    else
      @message = "There was an error"
    end
  end

  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to mailer_subscription_unsubcribe_path(params[:id], mailer: params[:mailer]), notice: "Subscription updated."
    else
      redirect_to mailer_subscription_unsubcribe_path(params[:id], mailer: params[:mailer]), notice: "There was an error."
    end
  end
  
  private
  
    def set_user
      @user = GlobalID::Locator.locate_signed params[:id]
      @message =  "There was an error" if @user.nil?
    end
  
    def set_mailer_subscription
      @mailer_subscription = MailerSubscription.find_or_initialize_by(
        user: @user,
        mailer: params[:mailer]
      )
    end

end
