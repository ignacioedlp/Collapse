# Configuración de Chartkick para Gráficos en ActiveAdmin

## ¿Qué es Chartkick?

Chartkick es una gema de Ruby que permite crear gráficos hermosos e interactivos con muy poco código. Es perfecta para dashboards de ActiveAdmin porque:

- ✅ **Fácil de usar**: Solo necesitas una línea de código para crear un gráfico
- ✅ **Interactivo**: Los gráficos son responsivos y tienen hover effects
- ✅ **Múltiples tipos**: Líneas, barras, circulares, áreas, etc.
- ✅ **Personalizable**: Colores, títulos, leyendas, etc.

## Instalación

### 1. Agregar las gemas al Gemfile

```ruby
# Charts for ActiveAdmin dashboard
gem 'chartkick'
gem 'groupdate'
```

### 2. Instalar las gemas

```bash
bundle install
```

### 3. Configuración automática

Chartkick se configura automáticamente, pero puedes personalizar la configuración en `config/initializers/chartkick.rb`.

## Tipos de Gráficos Disponibles

### 1. Gráfico de Línea (`line_chart`)
```ruby
line_chart daily_registrations_data(30), 
  title: "Registros Diarios",
  colors: ["#3498db"],
  curve: true,
  points: true
```

### 2. Gráfico de Barras (`column_chart`)
```ruby
column_chart weekly_registrations_data(8),
  title: "Registros Semanales",
  colors: ["#2ecc71"]
```

### 3. Gráfico Circular (`pie_chart`)
```ruby
pie_chart user_distribution_data,
  title: "Distribución de Usuarios",
  colors: ["#2ecc71", "#e74c3c", "#3498db", "#f39c12"]
```

### 4. Gráfico de Área (`area_chart`)
```ruby
area_chart monthly_growth_data(12),
  title: "Crecimiento Mensual",
  colors: ["#3498db"],
  curve: true
```

### 5. Gráfico de Barras Horizontal (`bar_chart`)
```ruby
bar_chart hourly_activity_data,
  title: "Actividad por Hora",
  colors: ["#e67e22"]
```

### 6. Gráfico de Dona (`pie_chart` con `donut: true`)
```ruby
pie_chart authentication_providers_data,
  title: "Método de Autenticación",
  colors: ["#9b59b6", "#1abc9c"],
  donut: true
```

## Implementación en el Dashboard

### Paso 1: Usar el dashboard con Chartkick

Una vez que instales las gemas, puedes usar el archivo de ejemplo:

```bash
# Renombrar el archivo de ejemplo
mv app/admin/dashboard_with_chartkick.rb app/admin/dashboard.rb
```

### Paso 2: Personalizar los datos

Los métodos helper en `app/helpers/dashboard_helper.rb` te permiten generar datos para diferentes tipos de gráficos:

- `daily_registrations_data(days)` - Registros diarios
- `weekly_registrations_data(weeks)` - Registros semanales
- `user_distribution_data` - Distribución de usuarios
- `authentication_providers_data` - Proveedores de autenticación
- `hourly_activity_data` - Actividad por hora
- `monthly_growth_data(months)` - Crecimiento mensual

### Paso 3: Agregar nuevos gráficos

Para agregar un nuevo gráfico, simplemente agrega un nuevo panel:

```ruby
panel 'Mi Nuevo Gráfico' do
  line_chart mi_datos_personalizados,
    title: "Mi Gráfico",
    colors: ["#mi-color"],
    curve: true
end
```

## Opciones de Personalización

### Colores
```ruby
colors: ["#3498db", "#2ecc71", "#e74c3c"]
```

### Títulos
```ruby
title: "Mi Gráfico Personalizado"
```

### Curvas suaves
```ruby
curve: true
```

### Puntos en líneas
```ruby
points: true
```

### Configuración avanzada de Chart.js
```ruby
library: {
  scales: {
    y: {
      beginAtZero: true,
      title: {
        display: true,
        text: 'Usuarios Registrados'
      }
    }
  },
  plugins: {
    legend: {
      position: 'bottom'
    }
  }
}
```

## Ejemplos de Datos

### Datos simples (Hash)
```ruby
{
  'Enero' => 10,
  'Febrero' => 15,
  'Marzo' => 20
}
```

### Datos con arrays
```ruby
[
  ['Enero', 10],
  ['Febrero', 15],
  ['Marzo', 20]
]
```

### Datos con múltiples series
```ruby
{
  'Usuarios' => {
    'Enero' => 10,
    'Febrero' => 15,
    'Marzo' => 20
  },
  'Ingresos' => {
    'Enero' => 1000,
    'Febrero' => 1500,
    'Marzo' => 2000
  }
}
```

## Troubleshooting

### Error: "undefined method 'line_chart'"
- Asegúrate de que Chartkick esté instalado: `bundle install`
- Verifica que la gema esté en el Gemfile

### Gráficos no se muestran
- Revisa la consola del navegador para errores de JavaScript
- Verifica que los datos no estén vacíos
- Asegúrate de que el formato de datos sea correcto

### Gráficos se ven mal en móvil
- Chartkick es responsivo por defecto
- Puedes ajustar el tamaño con CSS personalizado

## Recursos Adicionales

- [Documentación oficial de Chartkick](https://chartkick.com/)
- [Opciones de Chart.js](https://www.chartjs.org/docs/latest/)
- [Ejemplos de Chartkick](https://chartkick.com/examples)

## Próximos Pasos

Una vez que tengas Chartkick funcionando, puedes:

1. **Agregar más tipos de gráficos** (scatter, bubble, etc.)
2. **Implementar gráficos en tiempo real** con ActionCable
3. **Crear gráficos personalizados** con JavaScript
4. **Agregar filtros interactivos** para los gráficos
5. **Implementar exportación de gráficos** a PDF/PNG
