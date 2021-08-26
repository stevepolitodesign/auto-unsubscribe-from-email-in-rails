class MarketingMailer < ApplicationMailer
  before_action :set_user
  before_action :set_unsubscribe_url
  after_action :prevent_delivery_if_recipient_opted_out

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.marketing_mailer.promotion.subject
  #
  def promotion
    @message          = params[:message]
    @subject          = params[:subject]
    # TODO: Add a link to the settings page.
    mail to: @user.email, subject: @subject
  end
  
  private
  
  def prevent_delivery_if_recipient_opted_out
    if MailerSubscription::MAILERS.items.select{ |item| items[:class] == self.class.to_s }.present?
      mail.perform_deliveries = @user.subscribed_to_mailer? self.class.to_s
    else
      mail.perform_deliveries = true
    end
  end

  def set_user
    @user = params[:user]
  end
  
  def set_unsubscribe_url
    # TODO: Consider putting this in a private method in ApplicationMailer and call via a before_action where necesary
    @unsubscribe_url = mailer_subscription_unsubcribe_url(@user.to_sgid.to_s, mailer: self.class)
  end
end
