# Dashboard principal de ActiveAdmin
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Panel de estadísticas generales
    div class: "blank_slate_container", id: "dashboard_default_message" do
      columns do
        column do
          panel "Estadísticas de Usuarios" do
            para "Total de usuarios: #{User.count}"
            para "Usuarios confirmados: #{User.confirmed.count}"
            para "Usuarios sin confirmar: #{User.unconfirmed.count}"
            para "Usuarios de Google: #{User.google_users.count}"
            para "Usuarios locales: #{User.local_users.count}"
            para "Usuarios registrados hoy: #{User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count}"
            para "Usuarios registrados esta semana: #{User.where(created_at: 1.week.ago..Time.current).count}"
          end
        end

        column do
          panel "Estado del Sistema" do
            para "API Status: ✅ Operacional"
            para "Base de datos: ✅ Conectada"
            para "Google OAuth: #{GoogleAuthService.configured? ? '✅ Configurado' : '❌ No configurado'}"
            para "Versión: 1.0.0"
            para "Entorno: #{Rails.env.capitalize}"
            para "Última actualización: #{File.mtime(Rails.root.join('config', 'application.rb')).strftime('%d/%m/%Y %H:%M')}"
          end
        end
      end
    end

    # Gráfico de usuarios registrados por día (últimos 30 días)
    columns do
      column do
        panel "Registros de los Últimos 30 Días" do
          # Datos para el gráfico
          registrations_data = (30.days.ago.to_date..Date.current).map do |date|
            count = User.where(created_at: date.beginning_of_day..date.end_of_day).count
            [date.strftime('%d/%m'), count]
          end

          # Tabla simple con los datos
          table_for registrations_data do
            column("Fecha") { |data| data[0] }
            column("Registros") { |data| data[1] }
          end
        end
      end
    end

    # Últimos usuarios registrados
    columns do
      column do
        panel "Últimos Usuarios Registrados" do
          table_for User.order(created_at: :desc).limit(10) do
            column("Email") { |user| link_to user.email, admin_user_path(user) }
            column("Nombre") { |user| user.full_name }
            column("Proveedor") do |user|
              status_tag(user.google_user? ? "Google" : "Local", 
                        class: user.google_user? ? "ok" : "warning")
            end
            column("Estado") do |user|
              status_tag(user.confirmed? ? "Confirmado" : "Pendiente", 
                        class: user.confirmed? ? "ok" : "error")
            end
            column("Registrado") { |user| time_ago_in_words(user.created_at) + " ago" }
          end
        end
      end
    end

    # Enlaces rápidos
    columns do
      column do
        panel "Enlaces Rápidos" do
          ul do
            li link_to "Ver todos los usuarios", admin_users_path
            li link_to "Usuarios sin confirmar", admin_users_path(scope: :unconfirmed)
            li link_to "Usuarios de Google", admin_users_path(scope: :google_users)
            li link_to "API Info", "/api/info", target: "_blank"
            li link_to "Health Check", "/up", target: "_blank"
          end
        end
      end

      column do
        panel "Documentación" do
          ul do
            li link_to "Guía de la API", "#", target: "_blank"
            li link_to "Configuración de Google OAuth", "#", target: "_blank"
            li link_to "Ejemplos de uso", "/api/info", target: "_blank"
            li link_to "Repositorio en GitHub", "#", target: "_blank"
          end
        end
      end
    end

    # Información del sistema
    columns do
      column do
        panel "Información del Sistema" do
          attributes_table_for Rails.application do
            row("Versión de Rails") { Rails.version }
            row("Versión de Ruby") { RUBY_VERSION }
            row("Base de datos") { Rails.configuration.database_configuration[Rails.env]['adapter'] }
            row("Entorno") { Rails.env }
          end
        end
      end
    end
  end
end
