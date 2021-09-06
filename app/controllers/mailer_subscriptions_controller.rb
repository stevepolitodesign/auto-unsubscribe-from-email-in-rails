class MailerSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailer_subscription, only: :update
  before_action :handle_unauthorized, only: :update

  def index
    @mailer_subscriptions = MailerSubscription::MAILERS.items.map do |item|
      MailerSubscription.find_or_initialize_by(mailer: item[:class], user: current_user)
    end
  end

  def create
    @mailer_subscription = current_user.mailer_subscriptions.build(mailer_subscription_params)
    @mailer_subscription.subscribed = true
    if @mailer_subscription.save
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
      params.require(:mailer_subscription).permit(:mailer)
    end

    def set_mailer_subscription
      @mailer_subscription = MailerSubscription.find(params[:id])
    end

    def handle_unauthorized
      redirect_to root_path, status: :unauthorized, notice: "Unauthorized." and return if current_user != @mailer_subscription.user
    end
end
