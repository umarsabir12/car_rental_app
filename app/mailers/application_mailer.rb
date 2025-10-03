class ApplicationMailer < ActionMailer::Base
  default from: ENV['FROM_EMAIL'] || 'mumarsabir97@gmail.com'
  layout 'mailer'
end