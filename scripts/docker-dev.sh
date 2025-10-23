#!/bin/bash

# Script para desarrollo con Docker
echo "🐳 Rails BaaS - Desarrollo con Docker"

# Función para mostrar ayuda
show_help() {
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start     - Iniciar todos los servicios"
    echo "  stop      - Detener todos los servicios"
    echo "  restart   - Reiniciar todos los servicios"
    echo "  build     - Construir las imágenes"
    echo "  logs      - Ver logs de la aplicación"
    echo "  console   - Abrir consola Rails"
    echo "  db        - Conectar a PostgreSQL"
    echo "  clean     - Limpiar contenedores y volúmenes"
    echo "  help      - Mostrar esta ayuda"
    echo ""
}

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado."
    echo "   Instálalo desde: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado."
    echo "   Instálalo desde: https://docs.docker.com/compose/install/"
    exit 1
fi

# Procesar comando
case "${1:-start}" in
    "start")
        echo "🚀 Iniciando servicios..."
        docker compose up --build
        ;;
    
    "stop")
        echo "🛑 Deteniendo servicios..."
        docker compose down
        ;;
    
    "restart")
        echo "🔄 Reiniciando servicios..."
        docker compose down
        docker compose up --build
        ;;
    
    "build")
        echo "🔨 Construyendo imágenes..."
        docker compose build
        ;;
    
    "logs")
        echo "📋 Mostrando logs..."
        docker compose logs -f app
        ;;
    
    "console")
        echo "💻 Abriendo consola Rails..."
        docker compose exec app rails console
        ;;
    
    "db")
        echo "🐘 Conectando a PostgreSQL..."
        docker compose exec db psql -U postgres -d rails_baas_development
        ;;
    
    "clean")
        echo "🧹 Limpiando contenedores y volúmenes..."
        docker compose down -v
        docker system prune -f
        ;;
    
    "help"|"-h"|"--help")
        show_help
        ;;
    
    *)
        echo "❌ Comando desconocido: $1"
        show_help
        exit 1
        ;;
esac
