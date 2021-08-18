class MarketingMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.marketing_mailer.promotion.subject
  #
  def promotion
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
