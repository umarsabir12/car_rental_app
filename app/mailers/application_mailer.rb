class ApplicationMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL'] || 'no-reply@wheelsonrent.com'
  layout 'mailer'
end