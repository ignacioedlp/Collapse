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
        status_tag "Google", class: "ok"
      else
        status_tag "Local", class: "warning"
      end
    end
    
    column :confirmed do |user|
      status_tag(user.confirmed? ? "Sí" : "No", class: user.confirmed? ? "ok" : "error")
    end
    
    column :roles do |user|
      user.roles.map { |role| status_tag(role.name, class: "ok") }.join(" ").html_safe
    end
    
    column :created_at do |user|
      user.created_at.strftime("%d/%m/%Y %H:%M")
    end
    
    column :updated_at do |user|
      user.updated_at.strftime("%d/%m/%Y %H:%M")
    end
    
    actions
  end

  # Filtros en la barra lateral
  filter :email
  filter :first_name
  filter :last_name
  filter :provider, as: :select, collection: [['Local', nil], ['Google', 'google']]
  filter :confirmed_at
  filter :created_at
  filter :updated_at

  # Configuración del formulario de edición
  form do |f|
    f.inputs "Información del Usuario" do
      f.input :email, hint: "El email del usuario"
      f.input :first_name, hint: "Nombre del usuario"
      f.input :last_name, hint: "Apellido del usuario"
    end
    
    f.inputs "Estado" do
      f.input :confirmed_at, as: :datetime_picker, hint: "Fecha de confirmación (dejar vacío si no está confirmado)"
    end
    
    f.inputs "Roles" do
      f.input :roles, as: :check_boxes, collection: Role.all, hint: "Selecciona los roles del usuario"
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
          status_tag "Google", class: "ok"
        else
          status_tag "Local", class: "warning"
        end
      end
      
      row :google_id do |user|
        user.google_id || "N/A"
      end
      
      row :confirmed do |user|
        status_tag(user.confirmed? ? "Sí" : "No", class: user.confirmed? ? "ok" : "error")
      end
      
      row :confirmed_at do |user|
        user.confirmed_at&.strftime("%d/%m/%Y %H:%M") || "No confirmado"
      end
      
      row :created_at do |user|
        user.created_at.strftime("%d/%m/%Y %H:%M")
      end
      
      row :updated_at do |user|
        user.updated_at.strftime("%d/%m/%Y %H:%M")
      end
    end
    
    # Panel de acciones adicionales
    panel "Acciones" do
      if resource.confirmed?
        link_to "Desconfirmar Usuario", 
                admin_user_path(resource, user: { confirmed_at: nil }), 
                method: :patch, 
                class: "button",
                confirm: "¿Estás seguro de que quieres desconfirmar este usuario?"
      else
        link_to "Confirmar Usuario", 
                admin_user_path(resource, user: { confirmed_at: Time.current }), 
                method: :patch, 
                class: "button"
      end
    end
    
    # active_admin_comments
  end

  # Acciones personalizadas
  member_action :confirm, method: :patch do
    resource.confirm!
    redirect_to admin_user_path(resource), notice: "Usuario confirmado exitosamente"
  end

  member_action :unconfirm, method: :patch do
    resource.update!(confirmed_at: nil)
    redirect_to admin_user_path(resource), notice: "Usuario desconfirmado exitosamente"
  end

  # Acciones en lote
  batch_action :confirm do |ids|
    User.where(id: ids).update_all(confirmed_at: Time.current)
    redirect_to collection_path, notice: "Usuarios confirmados exitosamente"
  end

  batch_action :unconfirm do |ids|
    User.where(id: ids).update_all(confirmed_at: nil)
    redirect_to collection_path, notice: "Usuarios desconfirmados exitosamente"
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
    column :created_at
    column :updated_at
  end

  # Configuración de scope (pestañas)
  scope :all
  scope :confirmed
  scope :unconfirmed
  scope :google_users
  scope :local_users
end
