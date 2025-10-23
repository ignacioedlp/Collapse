# Configuración de ActiveAdmin para historial de baneos
ActiveAdmin.register BanLog do
  # Solo lectura - no permitir edición
  actions :index, :show

  # Configuración del índice
  index do
    selectable_column
    id_column
    
    column :user do |log|
      link_to log.user.full_name, admin_user_path(log.user)
    end
    
    column :action do |log|
      status_tag log.formatted_action, class: case log.action
        when 'banned', 'auto_banned' then 'error'
        when 'unbanned' then 'ok'
      end
    end
    
    column :reason do |log|
      truncate(log.reason, length: 40)
    end
    
    column :admin_user do |log|
      log.admin_user.email
    end
    
    column :duration do |log|
      log.duration_description
    end
    
    column :created_at do |log|
      log.created_at.strftime('%d/%m/%Y %H:%M')
    end
    
    actions defaults: false do |log|
      link_to 'Ver', admin_ban_log_path(log), class: 'member_link'
    end
  end

  # Filtros
  filter :user, as: :select, collection: -> { User.limit(100) }
  filter :admin_user, as: :select, collection: -> { AdminUser.all }
  filter :action, as: :select, collection: [
    ['Baneado manualmente', 'banned'],
    ['Baneado automáticamente', 'auto_banned'],
    ['Desbaneado', 'unbanned']
  ]
  filter :created_at
  filter :reason

  # Vista de detalles
  show do
    attributes_table do
      row :id
      row :user do |log|
        link_to log.user.full_name, admin_user_path(log.user)
      end
      row :action do |log|
        status_tag log.formatted_action
      end
      row :reason
      row :admin_user do |log|
        log.admin_user.email
      end
      row :banned_until do |log|
        log.banned_until&.strftime('%d/%m/%Y %H:%M') || 'Permanente'
      end
      row :duration do |log|
        log.duration_description
      end
      row :ip_address
      row :automatic do |log|
        log.automatic? ? 'Sí' : 'No'
      end
      row :created_at
    end
    
    if resource.user.present?
      panel 'Información del Usuario' do
        attributes_table_for resource.user do
          row :full_name
          row :email
          row :current_status do |user|
            if user.banned?
              status_tag user.ban_status, class: 'error'
            else
              status_tag 'Activo', class: 'ok'
            end
          end
          row :total_ban_logs do |user|
            user.ban_logs.count
          end
          row :reports_received do |user|
            user.received_reports.count
          end
        end
      end
    end
  end

  # Scopes
  scope :all
  scope :bans
  scope :unbans
  scope :auto_bans
  scope :recent

  # CSV export
  csv do
    column :id
    column :user do |log|
      log.user.full_name
    end
    column :user_email do |log|
      log.user.email
    end
    column :action
    column :reason
    column :admin_user do |log|
      log.admin_user.email
    end
    column :banned_until
    column :ip_address
    column :created_at
  end
end