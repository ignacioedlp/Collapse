# Configuración de ActiveAdmin para gestionar reportes de usuarios
ActiveAdmin.register Report do
  # Permisos
  permit_params :status, :admin_notes, :reviewed_by_id

  # Configuración del índice
  index do
    selectable_column
    id_column
    
    column :reported_user do |report|
      link_to report.reported_user.full_name, admin_user_path(report.reported_user)
    end
    
    column :reporter do |report|
      link_to report.reporter.full_name, admin_user_path(report.reporter)
    end
    
    column :reason do |report|
      status_tag report.formatted_reason, class: case report.reason
        when 'threats' then 'error'
        when 'harassment' then 'warning' 
        when 'spam' then 'notice'
        else 'default'
      end
    end
    
    column :description do |report|
      truncate(report.description, length: 50)
    end
    
    column :status do |report|
      status_tag report.formatted_status, class: case report.status
        when 'pending' then 'warning'
        when 'reviewed' then 'notice'
        when 'resolved' then 'ok'
        when 'dismissed' then 'default'
      end
    end
    
    column :created_at do |report|
      report.created_at.strftime('%d/%m/%Y %H:%M')
    end
    
    actions
  end

  # Filtros
  filter :reported_user, as: :select, collection: -> { User.limit(100) }
  filter :reporter, as: :select, collection: -> { User.limit(100) }
  filter :reason, as: :select, collection: Report.reasons_for_select
  filter :status, as: :select, collection: Report.statuses_for_select
  filter :created_at
  filter :description

  # Vista de detalles
  show do
    attributes_table do
      row :id
      row :reported_user do |report|
        link_to report.reported_user.full_name, admin_user_path(report.reported_user)
      end
      row :reporter do |report|
        link_to report.reporter.full_name, admin_user_path(report.reporter)
      end
      row :reason do |report|
        status_tag report.formatted_reason
      end
      row :description
      row :status do |report|
        status_tag report.formatted_status
      end
      row :ip_address
      row :reviewed_by do |report|
        report.reviewed_by&.email || 'No revisado'
      end
      row :admin_notes
      row :created_at
      row :updated_at
    end
    
    panel 'Acciones de Moderación' do
      if resource.pending?
        form action: mark_reviewed_admin_report_path(resource), method: :patch do
          input type: :text, name: :admin_notes, placeholder: 'Notas del administrador (opcional)'
          input type: :submit, value: 'Marcar como Revisado', class: 'button'
        end
        br
        form action: resolve_admin_report_path(resource), method: :patch do
          input type: :text, name: :admin_notes, placeholder: 'Notas de resolución'
          input type: :submit, value: 'Resolver Reporte', class: 'button'
        end
        br
        form action: dismiss_admin_report_path(resource), method: :patch do
          input type: :text, name: :admin_notes, placeholder: 'Razón del desestimado'
          input type: :submit, value: 'Desestimar', class: 'button'
        end
      end
      
      if resource.reported_user.present? && !resource.reported_user.banned?
        link_to 'Banear Usuario Reportado',
          new_ban_admin_user_path(resource.reported_user),
          class: 'button',
          style: 'background: #dc3545; color: white;'
      end
    end
  end

  # Acciones personalizadas
  member_action :mark_reviewed, method: :patch do
    notes = params[:admin_notes]
    resource.mark_as_reviewed!(current_admin_user, notes)
    redirect_to admin_report_path(resource), notice: 'Reporte marcado como revisado'
  end

  member_action :resolve, method: :patch do
    notes = params[:admin_notes]
    resource.resolve!(current_admin_user, notes)
    redirect_to admin_report_path(resource), notice: 'Reporte resuelto exitosamente'
  end

  member_action :dismiss, method: :patch do
    notes = params[:admin_notes]
    resource.dismiss!(current_admin_user, notes)
    redirect_to admin_report_path(resource), notice: 'Reporte desestimado'
  end

  # Scopes
  scope :all
  scope :pending
  scope :reviewed
  scope :resolved
  scope :dismissed

  # CSV export
  csv do
    column :id
    column :reported_user do |report|
      report.reported_user.full_name
    end
    column :reporter do |report|
      report.reporter.full_name
    end
    column :reason
    column :description
    column :status
    column :created_at
    column :reviewed_by do |report|
      report.reviewed_by&.email
    end
  end
end