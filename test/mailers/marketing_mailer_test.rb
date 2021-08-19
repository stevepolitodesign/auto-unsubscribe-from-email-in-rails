require "test_helper"

class MarketingMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @user = users(:one)
  end

  test "promotion" do
    mail = MarketingMailer.with(
      user: @user,
      message: "Some message",
      subject: "Some subject",
    ).promotion
    assert_equal "Some subject", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Some message", mail.body.encoded
    assert_match @user.to_sgid.to_s, mail.body.encoded
  end

  test "should prevent delivery" do
    assert_no_emails do
      MarketingMailer.with(
        user: @user,
        message: "Some message",
        subject: "Some subject",
      ).promotion.deliver_now
    end

    @user.mailer_subscriptions.create(
      mailer: "MarketingMailer",
      subscribed: true
    )

    assert_emails 1 do
      MarketingMailer.with(
        user: @user,
        message: "Some message",
        subject: "Some subject",
      ).promotion.deliver_now
    end    
  end

end
