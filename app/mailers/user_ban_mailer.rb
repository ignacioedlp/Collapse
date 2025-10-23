class UserBanMailer < ApplicationMailer
  default from: 'noreply@collapse.app'

  def ban_notification(user, ban_log)
    @user = user
    @ban_log = ban_log
    @reason = ban_log.reason
    @banned_until = ban_log.banned_until
    @admin_email = ban_log.admin_user.email
    @is_temporary = @banned_until.present?

    mail(
      to: @user.email,
      subject: @is_temporary ? 'Cuenta Suspendida Temporalmente' : 'Cuenta Suspendida'
    )
  end

  def unban_notification(user, admin_user = nil)
    @user = user
    @admin_email = admin_user&.email || 'Sistema'
    @support_email = 'support@collapse.app'

    mail(
      to: @user.email,
      subject: 'Cuenta Reactivada'
    )
  end
end
