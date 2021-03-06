require "test_helper"

class MailerSubscriptionUnsubcribesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should create" do
    assert_difference("MailerSubscription.count", 1) do
      get mailer_subscription_unsubcribe_path(@user.to_sgid.to_s, mailer: "MarketingMailer")
    end

    assert_not MailerSubscription.last.subscribed?
    assert_match "successfully unsubscribed", @response.parsed_body
  end

  test "should handle bad token" do
    get mailer_subscription_unsubcribe_path("a bad token", mailer: "MarketingMailer")
    assert_match "There was an error", @response.body
  end

  test "should update" do
    put mailer_subscription_unsubcribe_path(@user.to_sgid.to_s, mailer: "MarketingMailer")
    assert MailerSubscription.last.subscribed?
    assert_redirected_to root_path
  end
end
