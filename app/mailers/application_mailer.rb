class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@elgrocer.com"
  layout 'mailer'
end
