class MarketingMailer < ApplicationMailer
  after_action :prevent_delivery_if_recipient_opted_out

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.marketing_mailer.promotion.subject
  #
  def promotion
    @user             = params[:user]
    @message          = params[:message]
    @subject          = params[:subject]
    # TODO: Consider putting this in a private method in ApplicationMailer and call via a before_action where necesary
    @unsubscribe_url  = mailer_subscription_unsubcribe_url(@user.to_sgid.to_s, mailer: self.class)

    mail to: @user.email, subject: @subject
  end

  private

    def prevent_delivery_if_recipient_opted_out
      mail.perform_deliveries = @user.subscribed_to_mailer? self.class.to_s
    end
end
