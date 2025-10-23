# Preview all emails at http://localhost:3000/rails/mailers/user_ban_mailer
class UserBanMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_ban_mailer/ban_notification
  def ban_notification
    UserBanMailer.ban_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_ban_mailer/unban_notification
  def unban_notification
    UserBanMailer.unban_notification
  end

end
