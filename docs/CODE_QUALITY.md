# Guía de Calidad de Código

Este documento describe las herramientas y estándares de calidad de código configurados en este proyecto Rails.

## 🛠️ Herramientas Configuradas

### 1. RuboCop
RuboCop es el linter principal para Ruby. Se encarga de:
- Verificar el estilo del código
- Detectar problemas de rendimiento
- Aplicar convenciones de Rails
- Encontrar código potencialmente problemático

**Comandos útiles:**
```bash
# Verificar todo el código
docker compose exec app bundle exec rubocop app/

# Verificar un archivo específico
docker compose exec app bundle exec rubocop app/models/user.rb

# Corregir automáticamente los problemas que se puedan
docker compose exec app bundle exec rubocop app/ -a

# Corregir automáticamente y mostrar los cambios
docker compose exec app bundle exec rubocop app/ -a --display-cop-names
```

### 2. Standard
Standard es una herramienta adicional que complementa RuboCop con reglas más estrictas.

**Comandos útiles:**
```bash
# Verificar todo el código
docker compose exec app bundle exec standardrb app/

# Corregir automáticamente
docker compose exec app bundle exec standardrb app/ --fix

# Verificar un archivo específico
docker compose exec app bundle exec standardrb app/controllers/users_controller.rb
```

### 3. Brakeman
Brakeman es un analizador de seguridad que detecta vulnerabilidades comunes en aplicaciones Rails.

**Comandos útiles:**
```bash
# Ejecutar análisis de seguridad
docker compose exec app bundle exec brakeman

# Generar reporte HTML
docker compose exec app bundle exec brakeman -o brakeman-report.html

# Ejecutar en modo silencioso
docker compose exec app bundle exec brakeman --no-progress --quiet
```

### 4. RSpec
RSpec es el framework de testing que verifica que tu código funcione correctamente.

**Comandos útiles:**
```bash
# Ejecutar todos los tests
docker compose exec app bundle exec rspec

# Ejecutar tests de un archivo específico
docker compose exec app bundle exec rspec spec/models/user_spec.rb

# Ejecutar tests con más detalles
docker compose exec app bundle exec rspec --format documentation
```

## 🔄 Pre-commit Hooks

Hemos configurado hooks de Git que se ejecutan automáticamente antes de cada commit. Estos hooks:

1. **Ejecutan RuboCop** - Verifica el estilo del código
2. **Ejecutan Standard** - Aplica reglas adicionales
3. **Ejecutan Brakeman** - Verifica la seguridad
4. **Ejecutan RSpec** - Verifica que los tests pasen

Si alguno de estos checks falla, el commit será bloqueado hasta que se corrijan los problemas.

## 📋 Reglas de Estilo Principales

### Naming Conventions (Convenciones de Nombrado)
- **Variables y métodos**: `snake_case`
- **Clases y módulos**: `CamelCase`
- **Constantes**: `UPPER_SNAKE_CASE`

### Formato
- **Longitud de línea**: Máximo 120 caracteres
- **Comillas**: Usar comillas simples para strings (RuboCop) / dobles (Standard)
- **Indentación**: 2 espacios

### Métodos
- **Longitud máxima**: 20 líneas
- **Complejidad**: Máximo 30 puntos ABC

### Clases
- **Longitud máxima**: 200 líneas

## 🚀 Flujo de Trabajo Recomendado

1. **Desarrollo**: Escribe tu código normalmente
2. **Antes de commit**: Los hooks se ejecutan automáticamente
3. **Si hay errores**: Corrige los problemas reportados
4. **Repite**: Hasta que todos los checks pasen
5. **Commit**: Una vez que todo esté limpio

## 🔧 Comandos de Mantenimiento

### Instalar las nuevas gemas
```bash
docker compose exec app bundle install
```

### Ejecutar todos los checks manualmente
```bash
./scripts/pre-commit
```

### Corregir automáticamente problemas de estilo
```bash
docker compose exec app bundle exec rubocop app/ -a
docker compose exec app bundle exec standardrb app/ --fix
```

## 🐳 Uso con Docker Compose

Este proyecto está configurado para usar Docker Compose. Todos los comandos de los linters deben ejecutarse dentro del contenedor:

```bash
# Ejemplo de uso
docker compose exec app bundle exec rubocop app/
docker compose exec app bundle exec standardrb app/
docker compose exec app bundle exec brakeman
```

## ⚠️ Nota sobre Configuración

Hay una diferencia en la configuración de comillas entre RuboCop y Standard:
- **RuboCop**: Configurado para usar comillas simples
- **Standard**: Configurado para usar comillas dobles

Esto puede causar conflictos. Se recomienda elegir uno de los dos estándares y ajustar la configuración del otro para que sean consistentes.

## 📚 Recursos Adicionales

- [RuboCop Documentation](https://rubocop.org/)
- [Standard Documentation](https://github.com/testdouble/standard)
- [Brakeman Documentation](https://brakemanscanner.org/)
- [RSpec Documentation](https://rspec.info/)

## 🤝 Contribución

Al contribuir a este proyecto, asegúrate de:

1. Seguir las convenciones de estilo establecidas
2. Ejecutar los tests antes de hacer commit
3. Verificar que no haya problemas de seguridad
4. Documentar cambios significativos

¡Mantener código limpio es responsabilidad de todos! 🧹✨
