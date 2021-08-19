require "test_helper"

class MailerSubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mailer_subscription = @user.mailer_subscriptions.build(mailer: "MarketingMailer")
  end

  test "should be valid" do
    assert @mailer_subscription.valid?
  end

  test "should be unique accross mailer and user" do
    @mailer_subscription.save
    @duplicate_mailer_subscription = @user.mailer_subscriptions.build(subscribed: true, mailer: "MarketingMailer")
    assert_not @duplicate_mailer_subscription.valid?
  end

end
