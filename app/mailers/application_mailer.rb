class ApplicationMailer < ActionMailer::Base
  default from: (Rails.application.credentials.dig(:smtp, :from) || "from@example.com")
  layout nil
end
