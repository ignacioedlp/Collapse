# Configuración de Chartkick para gráficos en ActiveAdmin
# Este archivo se activará una vez que instales las gemas chartkick y groupdate

# Solo configurar Chartkick si la gema está disponible
if defined?(Chartkick)
  # Configuración global de Chartkick
  Chartkick.configure do |config|
    # Configurar el tema de colores para los gráficos
    config.colors = [
      "#3498db", # Azul
      "#2ecc71", # Verde
      "#e74c3c", # Rojo
      "#f39c12", # Naranja
      "#9b59b6", # Púrpura
      "#1abc9c", # Turquesa
      "#34495e", # Gris oscuro
      "#e67e22"  # Naranja oscuro
    ]
    
    # Configurar el idioma
    config.language = "es"
    
    # Configurar el tema
    config.theme = "light"
    
    # Configurar opciones por defecto para diferentes tipos de gráficos
    config.default_options = {
      # Opciones para gráficos de línea
      line_chart: {
        curve: true,
        points: true,
        colors: ["#3498db"],
        library: {
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: "#f0f0f0"
              }
            },
            x: {
              grid: {
                color: "#f0f0f0"
              }
            }
          },
          plugins: {
            legend: {
              display: true,
              position: 'top'
            }
          }
        }
      },
      
      # Opciones para gráficos de barras
      column_chart: {
        colors: ["#3498db"],
        library: {
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: "#f0f0f0"
              }
            },
            x: {
              grid: {
                color: "#f0f0f0"
              }
            }
          },
          plugins: {
            legend: {
              display: true,
              position: 'top'
            }
          }
        }
      },
      
      # Opciones para gráficos circulares
      pie_chart: {
        library: {
          plugins: {
            legend: {
              display: true,
              position: 'bottom'
            }
          }
        }
      },
      
      # Opciones para gráficos de área
      area_chart: {
        curve: true,
        colors: ["#3498db"],
        library: {
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: "#f0f0f0"
              }
            },
            x: {
              grid: {
                color: "#f0f0f0"
              }
            }
          },
          plugins: {
            legend: {
              display: true,
              position: 'top'
            }
          }
        }
      }
    }
  end
else
  # Mensaje informativo cuando Chartkick no está disponible
  Rails.logger.info "Chartkick no está instalado. Los gráficos del dashboard mostrarán datos en formato de tabla."
end
