class MailerSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailer_subscription, only: :update

  def index
    @mailer_subscriptions = MailerSubscription::MAILERS.items.map do |item|
      MailerSubscription.find_or_initialize_by(mailer: item[:class], user: current_user)
    end
  end

  def create
    @mailer_subscription = current_user.mailer_subscriptions.build(mailer_subscription_params)
    if @mailer_subscription.save?
      redirect_to mailer_subscriptions_path, notice: "Preferences updated."
    else
      redirect_to mailer_subscriptions_path, alter: "#{@mailer_subscription.errors.full_messages.to_sentence}"
    end
  end

  def update
    if @mailer_subscription.toggle!(:subscribed)
      redirect_to mailer_subscriptions_path, notice: "Preferences updated."
    else
      redirect_to mailer_subscriptions_path, alter: "#{@mailer_subscription.errors.full_messages.to_sentence}"
    end
  end

  private

    def mailer_subscription_params
      params.require(:mailer_subscription).permit(:mailer, :subscribed, :user_id)
    end

    def set_mailer_subscription
      @mailer_subscription = MailerSubscription.find(params[:id])
    end
end
