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

  test "should have mailer" do
    @mailer_subscription.mailer = nil
    assert_not @mailer_subscription.valid?
  end

  test "mailer should be in list" do
    invalid_mailers = %w(Foo Bar Baz)
    invalid_mailers.each do |invalid_mailer|
      @mailer_subscription.mailer = invalid_mailer
      assert_not @mailer_subscription.valid?
    end
  end

end
