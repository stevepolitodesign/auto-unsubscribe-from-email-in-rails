require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "notify" do
    mail = NotificationMailer.with(
      user: @user
    ).notify
    assert_equal "Notify", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "should prevent delivery" do
    assert_no_emails do
      NotificationMailer.with(
        user: @user,
      ).notify.deliver_now
    end

    @user.mailer_subscriptions.create(
      mailer: "NotificationMailer",
      subscribed: true
    )

    assert_emails 1 do
      NotificationMailer.with(
        user: @user,
      ).notify.deliver_now
    end    
  end  

end
