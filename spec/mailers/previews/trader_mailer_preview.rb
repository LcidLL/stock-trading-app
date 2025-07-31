# Preview all emails at http://localhost:3000/rails/mailers/trader_mailer_mailer
class TraderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/trader_mailer_mailer/approval_notification
  def approval_notification
    TraderMailer.approval_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/trader_mailer_mailer/rejection_notification
  def rejection_notification
    TraderMailer.rejection_notification
  end

end
