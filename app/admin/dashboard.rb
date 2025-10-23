# Dashboard principal de ActiveAdmin
ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    # Panel de estadísticas generales
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      columns do
        column do
          panel 'Estadísticas de Usuarios' do
            para "Total de usuarios: #{User.count}"
            para "Usuarios confirmados: #{User.confirmed.count}"
            para "Usuarios sin confirmar: #{User.unconfirmed.count}"
            para "Usuarios de Google: #{User.google_users.count}"
            para "Usuarios locales: #{User.local_users.count}"
            para "Usuarios registrados hoy: #{User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count}"
            para "Usuarios registrados esta semana: #{User.where(created_at: 1.week.ago..Time.current).count}"
          end
          
          panel 'Estadísticas de Baneos' do
            total_users = User.count
            banned_users = User.banned.count
            active_users = User.not_banned.count
            permanent_bans = User.permanently_banned.count
            temporary_bans = User.temporarily_banned.count
            
            para "👥 Total de usuarios: #{total_users}"
            para "✅ Usuarios activos: #{active_users} (#{total_users > 0 ? ((active_users.to_f / total_users) * 100).round(1) : 0}%)"
            para "🚫 Usuarios baneados: #{banned_users} (#{total_users > 0 ? ((banned_users.to_f / total_users) * 100).round(1) : 0}%)"
            para "⏳ Baneos temporales: #{temporary_bans}"
            para "🔒 Baneos permanentes: #{permanent_bans}"
            
            if defined?(BanLog)
              bans_today = BanLog.bans.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count
              bans_week = BanLog.bans.where('created_at >= ?', 1.week.ago).count
              unbans_week = BanLog.unbans.where('created_at >= ?', 1.week.ago).count
              
              para "📅 Baneos hoy: #{bans_today}"
              para "📊 Baneos esta semana: #{bans_week}"
              para "🔓 Desbaneos esta semana: #{unbans_week}"
            end
          end
        end

        column do
          panel 'Estado del Sistema' do
            para 'API Status: ✅ Operacional'
            para 'Base de datos: ✅ Conectada'
            para "Google OAuth: #{GoogleAuthService.configured? ? "✅ Configurado" : "❌ No configurado"}"
            para 'Versión: 1.0.0'
            para "Entorno: #{Rails.env.capitalize}"
            para "Última actualización: #{File.mtime(Rails.root.join("config",
              "application.rb")).strftime("%d/%m/%Y %H:%M")}"
          end
        end
      end
    end

    # Datos de registros diarios (últimos 7 días)
    columns do
      column do
        panel 'Registros de Usuarios - Últimos 7 Días' do
          # Datos para el gráfico
          registrations_data = (7.days.ago.to_date..Date.current).map do |date|
            count = User.where(created_at: date.beginning_of_day..date.end_of_day).count
            [date.strftime('%d/%m'), count]
          end

          # Tabla simple con los datos
          table_for registrations_data do
            column('Fecha') { |data| data[0] }
            column('Registros') { |data| data[1] }
          end
          
          # Resumen
          total_registrations = registrations_data.sum { |data| data[1] }
          para "Total de registros en los últimos 7 días: #{total_registrations}"
        end
      end

      column do
        panel 'Distribución de Usuarios' do
          # Datos de distribución
          confirmed_count = User.confirmed.count
          unconfirmed_count = User.unconfirmed.count
          google_count = User.google_users.count
          local_count = User.local_users.count

          # Tabla de distribución
          table_for [
            ['Confirmados', confirmed_count],
            ['Sin confirmar', unconfirmed_count],
            ['Google OAuth', google_count],
            ['Local', local_count]
          ] do
            column('Categoría') { |data| data[0] }
            column('Cantidad') { |data| data[1] }
          end
          
          # Resumen
          total_users = confirmed_count + unconfirmed_count
          para "Total de usuarios: #{total_users}"
        end
      end
    end

    # Datos semanales
    columns do
      column do
        panel 'Tendencia Semanal de Registros' do
          # Datos semanales
          weekly_data = (4.weeks.ago.to_date..Date.current).step(7).map do |week_start|
            week_end = week_start + 6.days
            count = User.where(created_at: week_start.beginning_of_day..week_end.end_of_day).count
            ["Semana #{week_start.strftime('%d/%m')}", count]
          end

          # Tabla semanal
          table_for weekly_data do
            column('Semana') { |data| data[0] }
            column('Registros') { |data| data[1] }
          end
          
          # Resumen
          total_weekly = weekly_data.sum { |data| data[1] }
          para "Total de registros en las últimas 4 semanas: #{total_weekly}"
        end
      end

      column do
        panel 'Proveedores de Autenticación' do
          # Datos de proveedores
          google_count = User.google_users.count
          local_count = User.local_users.count

          # Tabla de proveedores
          table_for [
            ['Google OAuth', google_count],
            ['Email/Password', local_count]
          ] do
            column('Proveedor') { |data| data[0] }
            column('Usuarios') { |data| data[1] }
          end
          
          # Resumen
          total_auth = google_count + local_count
          if total_auth > 0
            google_percent = ((google_count.to_f / total_auth) * 100).round(1)
            local_percent = ((local_count.to_f / total_auth) * 100).round(1)
            para "Google OAuth: #{google_percent}% | Local: #{local_percent}%"
          end
        end
      end
    end

    # Últimos usuarios registrados
    columns do
      column do
        panel 'Últimos Usuarios Registrados' do
          table_for User.order(created_at: :desc).limit(10) do
            column('Email') { |user| link_to user.email, admin_user_path(user) }
            column('Nombre', &:full_name)
            column('Proveedor') do |user|
              status_tag(user.google_user? ? 'Google' : 'Local',
                class: user.google_user? ? 'ok' : 'warning')
            end
            column('Estado') do |user|
              status_tag(user.confirmed? ? 'Confirmado' : 'Pendiente',
                class: user.confirmed? ? 'ok' : 'error')
            end
            column('Registrado') { |user| "#{time_ago_in_words(user.created_at)} ago" }
          end
        end
      end
    end

    # Enlaces rápidos
    columns do
      column do
        panel 'Enlaces Rápidos' do
          ul do
            li link_to 'Ver todos los usuarios', admin_users_path
            li link_to 'Usuarios sin confirmar', admin_users_path(scope: :unconfirmed)
            li link_to 'Usuarios de Google', admin_users_path(scope: :google_users)
            li link_to 'API Info', '/api/info', target: '_blank'
            li link_to 'Health Check', '/up', target: '_blank'
            li link_to '📚 API Documentation (Swagger)', '/api-docs', target: '_blank',
              style: 'color: #3498db; font-weight: bold;'
          end
        end
      end

      column do
        panel 'Documentación' do
          ul do
            li link_to '📚 API Documentation (Swagger)', '/api-docs', target: '_blank',
              style: 'color: #3498db; font-weight: bold;'
            li link_to '🔧 API Info & Examples', '/api/info', target: '_blank'
            li link_to '⚙️ Configuración de Google OAuth', '#', target: '_blank'
            li link_to '📖 Guía de Desarrollo', '#', target: '_blank'
            li link_to '🐙 Repositorio en GitHub', '#', target: '_blank'
          end
        end
      end
    end

    # Actividad reciente de baneos
    if defined?(BanLog)
      columns do
        column do
          panel 'Actividad Reciente de Baneos' do
            recent_logs = BanLog.includes(:user, :admin_user).recent.limit(10)
            if recent_logs.any?
              table_for recent_logs do
                column('Usuario') do |log|
                  link_to log.user.full_name, admin_user_path(log.user)
                end
                column('Acción') { |log| status_tag log.formatted_action, class: log.ban_action? ? 'error' : 'ok' }
                column('Razón') { |log| truncate(log.reason, length: 50) }
                column('Admin') { |log| log.admin_user.email }
                column('Fecha') { |log| "#{time_ago_in_words(log.created_at)} ago" }
              end
            else
              para 'No hay actividad de baneos registrada.'
            end
          end
        end
        
        column do
          panel 'Usuarios Recientemente Baneados' do
            recently_banned = User.banned.includes(:banned_by).order(banned_at: :desc).limit(5)
            if recently_banned.any?
              table_for recently_banned do
                column('Usuario') do |user|
                  link_to user.full_name, admin_user_path(user)
                end
                column('Estado') { |user| status_tag user.ban_status, class: 'error' }
                column('Baneado por') { |user| user.banned_by&.email || 'Sistema' }
                column('Fecha') { |user| "#{time_ago_in_words(user.banned_at)} ago" }
              end
            else
              para 'No hay usuarios baneados actualmente.'
            end
          end
        end
      end
    end

    # Información del sistema
    columns do
      column do
        panel 'Información del Sistema' do
          attributes_table_for Rails.application do
            row('Versión de Rails') { Rails.version }
            row('Versión de Ruby') { RUBY_VERSION }
            row('Base de datos') { Rails.configuration.database_configuration[Rails.env]['adapter'] }
            row('Entorno') { Rails.env }
          end
        end
      end
    end
  end
end
