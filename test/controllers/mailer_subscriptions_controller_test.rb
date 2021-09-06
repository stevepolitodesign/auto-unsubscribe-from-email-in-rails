require "test_helper"

class MailerSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user = users(:one)
  end 

  test "should create" do
    sign_in @user
    get mailer_subscriptions_path

    assert_difference("MailerSubscription.count", 1) do
      post mailer_subscriptions_path, params: {
        mailer_subscription: @user.mailer_subscriptions.build(mailer: "MarketingMailer").attributes
      }
    end

    assert_redirected_to mailer_subscriptions_path
  end

  test "should update" do
    @mailer_subscription = @user.mailer_subscriptions.create(mailer: "MarketingMailer", subscribed: true)
    
    sign_in @user
    put mailer_subscription_path(@mailer_subscription)
    
    assert_not @mailer_subscription.reload.subscribed?
    assert_redirected_to mailer_subscriptions_path
  end

  test "should handle unauthorized" do
    @mailer_subscription = @user.mailer_subscriptions.create(mailer: "MarketingMailer", subscribed: true)

    sign_in users(:two)
    put mailer_subscription_path(@mailer_subscription)

    assert_equal 401, @response.status
  end


end
