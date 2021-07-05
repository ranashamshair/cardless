# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'distropayment@gmail.com'
  layout 'mailer'
end
