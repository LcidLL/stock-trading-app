class TraderMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']

  def approval_notification(trader)
    @trader = trader
    @login_url = root_url
    mail(
      to: @trader.email,
      subject: 'Your Stock Trading Account Has Been Approved!'
    )
  end

  def rejection_notification(trader)
    @trader = trader
    @support_email = ENV['GMAIL_USERNAME']
    mail(
      to: @trader.email,
      subject: 'Update on Your Stock Trading Account Application'
    )
  end
end