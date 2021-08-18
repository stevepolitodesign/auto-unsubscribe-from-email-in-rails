# Preview all emails at http://localhost:3000/rails/mailers/marketing_mailer
class MarketingMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/marketing_mailer/promotion
  def promotion
    MarketingMailer.with(
      user: User.first,
      message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.",
      subject: "Limited time offer!"
    ).promotion
  end

end
