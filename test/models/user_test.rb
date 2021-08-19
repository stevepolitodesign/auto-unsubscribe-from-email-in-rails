require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "user#subscribed_to_mailer?" do
    assert_not @user.subscribed_to_mailer? "MarketingMailer"

    @user.mailer_subscriptions.create(
      mailer: "MarketingMailer",
      subscribed: true
    )

    assert @user.subscribed_to_mailer? "MarketingMailer"
  end
end
