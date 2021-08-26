class ApplicationMailer < ActionMailer::Base
  before_action :set_user
  before_action :set_unsubscribe_url
  after_action :prevent_delivery_if_recipient_opted_out

  default from: 'from@example.com'
  layout 'mailer'

  private
  
  def prevent_delivery_if_recipient_opted_out
    if MailerSubscription::MAILERS.items.select{ |item| item[:class] == self.class.to_s }.present?
      mail.perform_deliveries = @user.subscribed_to_mailer? self.class.to_s
    else
      mail.perform_deliveries = true
    end
  end

  def set_user
    @user = params[:user]
  end
  
  def set_unsubscribe_url
    @unsubscribe_url = mailer_subscription_unsubcribe_url(@user.to_sgid.to_s, mailer: self.class)
  end  
end
