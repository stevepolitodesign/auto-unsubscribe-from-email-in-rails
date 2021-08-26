# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/notify
  def notify
    NotificationMailer.with(
      user: User.first
    ).notify
  end

end
