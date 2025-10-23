#!/bin/bash

# Script de configuración inicial para Rails BaaS
echo "🚀 Configurando Rails BaaS..."

# Verificar que Ruby y Rails están instalados
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby no está instalado. Por favor instala Ruby 3.1+"
    exit 1
fi

if ! command -v rails &> /dev/null; then
    echo "❌ Rails no está instalado. Instalando..."
    gem install rails
fi

echo "✅ Ruby $(ruby --version)"
echo "✅ Rails $(rails --version)"

# Instalar dependencias
echo "📦 Instalando dependencias..."
bundle install

# Verificar PostgreSQL
echo "🐘 Verificando PostgreSQL..."
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL no está instalado localmente."
    echo "   Opciones:"
    echo "   1. Instalar PostgreSQL: https://postgresql.org/download/"
    echo "   2. Usar Docker: docker-compose up -d db"
    echo "   3. Usar un servicio en la nube (Heroku, AWS RDS, etc.)"
    echo ""
fi

# Configurar base de datos
echo "🗄️  Configurando base de datos..."
if rails db:create; then
    echo "✅ Base de datos creada"
    rails db:migrate
    rails db:seed
else
    echo "❌ Error al crear la base de datos"
    echo "   Asegúrate de que PostgreSQL esté ejecutándose"
    echo "   O usa Docker: docker-compose up -d db"
fi

# Crear archivo de configuración si no existe
if [ ! -f .env ]; then
    echo "⚙️  Creando archivo de configuración..."
    cp env.example .env
    echo "✅ Archivo .env creado. Edítalo con tus configuraciones."
fi

# Generar clave secreta
if ! grep -q "SECRET_KEY_BASE=" .env; then
    echo "🔐 Generando clave secreta..."
    SECRET_KEY=$(rails secret)
    echo "SECRET_KEY_BASE=$SECRET_KEY" >> .env
    echo "✅ Clave secreta generada"
fi

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Edita el archivo .env con tus configuraciones"
echo "2. Para Google OAuth, configura GOOGLE_CLIENT_ID"
echo "3. Inicia el servidor: rails server"
echo ""
echo "🌐 URLs importantes:"
echo "- API: http://localhost:3000"
echo "- Admin Panel: http://localhost:3000/admin"
echo "- API Info: http://localhost:3000/api/info"
echo ""
echo "🔑 Credenciales de admin:"
echo "- Email: admin@rails-baas.com"
echo "- Password: password123"
echo ""
echo "✨ ¡Disfruta tu BaaS!"
