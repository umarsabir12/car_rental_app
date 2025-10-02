class TestMailer < ApplicationMailer
  def test_email(user_email)
    @user_email = user_email
    mail(
      to: @user_email,
      subject: 'Test Email from Car Rental App'
    )
  end
end
