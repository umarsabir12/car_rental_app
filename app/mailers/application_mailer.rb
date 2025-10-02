class ApplicationMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL'] || 'noreply@sendgrid.net'
  layout 'mailer'
end