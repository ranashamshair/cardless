class NotificationMailer < ApplicationMailer

  def thankyou_email(merchant)
    @merchant  = merchant
    mail(to: @merchant.email, subject: "Verification data collected")
  end

  def verified(merchant)
    @merchant  = merchant
    mail(to: @merchant.email, subject: "Profile verified for doing payments")
  end

  def rejected(merchant)
    @merchant  = merchant
    mail(to: @merchant.email, subject: "Profile rejected")
  end

end
