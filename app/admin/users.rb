# Configuración de ActiveAdmin para gestionar usuarios
ActiveAdmin.register User do
  # Permisos: qué parámetros se pueden editar
  permit_params :email, :first_name, :last_name, :confirmed_at, :active

  # Configuración del índice (lista de usuarios)
  index do
    selectable_column
    id_column

    column :email do |user|
      link_to user.email, admin_user_path(user)
    end

    column :full_name

    column :provider do |user|
      if user.google_user?
        status_tag 'Google', class: 'ok'
      else
        status_tag 'Local', class: 'warning'
      end
    end

    column :confirmed do |user|
      status_tag(user.confirmed? ? 'Sí' : 'No', class: user.confirmed? ? 'ok' : 'error')
    end

    column :ban_status do |user|
      if user.banned?
        status_tag('Baneado', class: 'error')
      else
        status_tag('Activo', class: 'ok')
      end
    end

    column :roles do |user|
      user.roles.map { |role| role.name }.join(' ').html_safe
    end

    column :created_at do |user|
      user.created_at.strftime('%d/%m/%Y %H:%M')
    end

    column :updated_at do |user|
      user.updated_at.strftime('%d/%m/%Y %H:%M')
    end

    actions
  end

  # Configuración de controller para optimizar consultas
  controller do
    def scoped_collection
      # Solución específica para Rolify: usar distinct para evitar duplicados
      super.distinct.preload(:roles)
    end

    def find_resource
      User.preload(:roles).find(params[:id])
    end
  end

  # Filtros en la barra lateral
  filter :email
  filter :first_name
  filter :last_name
  filter :provider, as: :select, collection: [ [ 'Local', nil ], %w[Google google] ]
  filter :confirmed_at
  filter :banned_at
  filter :banned_reason
  filter :created_at
  filter :updated_at

  # Configuración del formulario de edición
  form do |f|
    f.inputs 'Información del Usuario' do
      f.input :email, hint: 'El email del usuario'
      f.input :first_name, hint: 'Nombre del usuario'
      f.input :last_name, hint: 'Apellido del usuario'
    end

    f.inputs 'Estado' do
      f.input :confirmed_at, as: :datetime_picker, hint: 'Fecha de confirmación (dejar vacío si no está confirmado)'
    end

    f.inputs 'Roles' do
      f.input :roles, as: :check_boxes, collection: Role.all, hint: 'Selecciona los roles del usuario'
    end

    f.actions
  end

  # Configuración de la vista de detalles
  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :full_name

      row :provider do |user|
        if user.google_user?
          status_tag 'Google', class: 'ok'
        else
          status_tag 'Local', class: 'warning'
        end
      end

      row :google_id do |user|
        user.google_id || 'N/A'
      end

      row :confirmed do |user|
        status_tag(user.confirmed? ? 'Sí' : 'No', class: user.confirmed? ? 'ok' : 'error')
      end

      row :confirmed_at do |user|
        user.confirmed_at&.strftime('%d/%m/%Y %H:%M') || 'No confirmado'
      end

      row :roles do |user|
        user.roles.map { |role| role.name }.join(' ').html_safe
      end

      row :ban_status do |user|
        if user.banned?
          status_tag user.ban_status, class: 'error'
        else
          status_tag 'Activo', class: 'ok'
        end
      end

      row :banned_at do |user|
        user.banned_at&.strftime('%d/%m/%Y %H:%M') || 'Nunca'
      end

      row :banned_reason do |user|
        user.banned_reason || 'N/A'
      end

      row :banned_until do |user|
        user.banned_until&.strftime('%d/%m/%Y %H:%M') || (user.banned_at ? 'Permanente' : 'N/A')
      end

      row :banned_by do |user|
        user.banned_by&.email || 'N/A'
      end

      row :created_at do |user|
        user.created_at.strftime('%d/%m/%Y %H:%M')
      end

      row :updated_at do |user|
        user.updated_at.strftime('%d/%m/%Y %H:%M')
      end
    end

    # Panel de acciones adicionales
    panel 'Acciones de Confirmación' do
      if resource.confirmed?
        link_to 'Desconfirmar Usuario',
          admin_user_path(resource, user: { confirmed_at: nil }),
          method: :patch,
          class: 'button',
          confirm: '¿Estás seguro de que quieres desconfirmar este usuario?'
      else
        link_to 'Confirmar Usuario',
          admin_user_path(resource, user: { confirmed_at: Time.current }),
          method: :patch,
          class: 'button'
      end
    end

    panel 'Acciones de Baneo' do
      if resource.banned?
        link_to 'Desbanear Usuario',
          unban_admin_user_path(resource),
          method: :patch,
          class: 'button',
          confirm: '¿Estás seguro de que quieres desbanear este usuario?'
      else
        link_to 'Banear Usuario',
          new_ban_admin_user_path(resource),
          class: 'button'
      end
    end

    # active_admin_comments
  end

  # Acciones personalizadas
  member_action :confirm, method: :patch do
    resource.confirm!
    redirect_to admin_user_path(resource), notice: 'Usuario confirmado exitosamente'
  end

  member_action :unconfirm, method: :patch do
    resource.update!(confirmed_at: nil)
    redirect_to admin_user_path(resource), notice: 'Usuario desconfirmado exitosamente'
  end

  # Acción para mostrar formulario de baneo
  member_action :new_ban, method: :get do
    @page_title = "Banear Usuario: #{resource.full_name}"
  end

  # Acción para procesar el baneo
  member_action :ban, method: :post do
    reason = params[:ban_reason]
    until_date = params[:ban_until].present? ? DateTime.parse(params[:ban_until]) : nil
    
    if reason.present?
      resource.ban!(reason: reason, admin_user: current_admin_user, until_date: until_date)
      redirect_to admin_user_path(resource), notice: 'Usuario baneado exitosamente'
    else
      redirect_to new_ban_admin_user_path(resource), alert: 'Debe proporcionar una razón para el baneo'
    end
  rescue StandardError => e
    redirect_to admin_user_path(resource), alert: "Error al banear usuario: #{e.message}"
  end

  # Acción para desbanear
  member_action :unban, method: :patch do
    resource.unban!(admin_user: current_admin_user)
    redirect_to admin_user_path(resource), notice: 'Usuario desbaneado exitosamente'
  rescue StandardError => e
    redirect_to admin_user_path(resource), alert: "Error al desbanear usuario: #{e.message}"
  end

  # Acciones en lote
  batch_action :confirm do |ids|
    User.where(id: ids).update_all(confirmed_at: Time.current)
    redirect_to collection_path, notice: 'Usuarios confirmados exitosamente'
  end

  batch_action :unconfirm do |ids|
    User.where(id: ids).update_all(confirmed_at: nil)
    redirect_to collection_path, notice: 'Usuarios desconfirmados exitosamente'
  end

  batch_action :ban, form: {
    reason: :text,
    until_date: :datetime_local
  } do |ids, inputs|
    reason = inputs['reason']
    until_date = inputs['until_date'].present? ? DateTime.parse(inputs['until_date']) : nil
    
    if reason.present?
      User.where(id: ids).find_each do |user|
        user.ban!(reason: reason, admin_user: current_admin_user, until_date: until_date)
      end
      redirect_to collection_path, notice: "#{ids.count} usuarios baneados exitosamente"
    else
      redirect_to collection_path, alert: 'Debe proporcionar una razón para el baneo'
    end
  end

  batch_action :unban do |ids|
    User.where(id: ids).find_each do |user|
      user.unban!(admin_user: current_admin_user) if user.banned?
    end
    redirect_to collection_path, notice: "#{ids.count} usuarios desbaneados exitosamente"
  end

  # Configuración de CSV export
  csv do
    column :id
    column :email
    column :first_name
    column :last_name
    column :provider
    column :google_id
    column :confirmed_at
    column :banned_at
    column :banned_reason
    column :banned_until
    column :created_at
    column :updated_at
  end

  # Configuración de scope (pestañas)
  scope :all
  scope :confirmed
  scope :unconfirmed
  scope :banned
  scope :not_banned
  scope :permanently_banned
  scope :temporarily_banned
  scope :google_users
  scope :local_users
end
