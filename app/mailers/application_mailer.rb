class ApplicationMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL'] || 'noreply@yourapp.herokuapp.com'
  layout 'mailer'
end