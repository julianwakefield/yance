require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "welcome_trainer" do
    mail = UserMailer.welcome_trainer
    assert_equal "Welcome trainer", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
