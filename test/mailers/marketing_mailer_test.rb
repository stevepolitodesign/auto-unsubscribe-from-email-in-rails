require "test_helper"

class MarketingMailerTest < ActionMailer::TestCase
  test "promotion" do
    mail = MarketingMailer.with(
      user: users(:one),
      message: "Some message",
      subject: "Some subject",
    ).promotion
    assert_equal "Some subject", mail.subject
    assert_equal [users(:one).email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Some message", mail.body.encoded
  end

end
