#!/bin/bash

# Script de troubleshooting para Rails BaaS
echo "🔍 Rails BaaS - Diagnóstico y Troubleshooting"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar estado
show_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Función para mostrar warning
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Función para mostrar info
show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo ""
echo "=== 🐳 DOCKER ==="

# Verificar Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    show_status 0 "Docker instalado: $DOCKER_VERSION"
    
    # Verificar que Docker esté ejecutándose
    if docker info &> /dev/null; then
        show_status 0 "Docker daemon ejecutándose"
    else
        show_status 1 "Docker daemon no está ejecutándose"
        show_info "Inicia Docker Desktop o ejecuta: sudo systemctl start docker"
    fi
else
    show_status 1 "Docker no está instalado"
    show_info "Instala Docker desde: https://docs.docker.com/get-docker/"
fi

# Verificar Docker Compose
if command -v docker compose &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    show_status 0 "Docker Compose instalado: $COMPOSE_VERSION"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    show_status 0 "Docker Compose (legacy) instalado: $COMPOSE_VERSION"
    show_warning "Usa 'docker compose' en lugar de 'docker-compose'"
else
    show_status 1 "Docker Compose no está instalado"
fi

echo ""
echo "=== 📁 ARCHIVOS ==="

# Verificar archivos importantes
files_to_check=("Gemfile" "docker-compose.yml" "Dockerfile" "config/database.yml")
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        show_status 0 "$file existe"
    else
        show_status 1 "$file no encontrado"
    fi
done

echo ""
echo "=== 🐘 POSTGRESQL ==="

# Verificar si PostgreSQL está ejecutándose en Docker
if docker compose ps db 2>/dev/null | grep -q "Up"; then
    show_status 0 "PostgreSQL ejecutándose en Docker"
    
    # Probar conexión
    if docker compose exec -T db pg_isready -U postgres &> /dev/null; then
        show_status 0 "PostgreSQL acepta conexiones"
    else
        show_status 1 "PostgreSQL no acepta conexiones"
    fi
else
    show_status 1 "PostgreSQL no está ejecutándose en Docker"
    show_info "Ejecuta: docker compose up -d db"
fi

echo ""
echo "=== 🚀 APLICACIÓN RAILS ==="

# Verificar si Rails está ejecutándose
if docker compose ps app 2>/dev/null | grep -q "Up"; then
    show_status 0 "Rails ejecutándose en Docker"
    
    # Probar endpoint de salud
    if curl -s http://localhost:3000/up &> /dev/null; then
        show_status 0 "Rails responde en http://localhost:3000"
    else
        show_status 1 "Rails no responde en puerto 3000"
        show_info "Verifica logs: docker compose logs app"
    fi
else
    show_status 1 "Rails no está ejecutándose en Docker"
    show_info "Ejecuta: docker compose up -d app"
fi

echo ""
echo "=== 🔧 SOLUCIONES COMUNES ==="

echo -e "${BLUE}Si tienes problemas:${NC}"
echo ""
echo "1. 🧹 Limpiar y reconstruir:"
echo "   docker compose down -v"
echo "   docker system prune -f"
echo "   docker compose up --build"
echo ""
echo "2. 📋 Ver logs detallados:"
echo "   docker compose logs app"
echo "   docker compose logs db"
echo ""
echo "3. 🐛 Entrar al contenedor para debug:"
echo "   docker compose exec app bash"
echo "   docker compose exec db psql -U postgres"
echo ""
echo "4. 🔄 Reiniciar solo un servicio:"
echo "   docker compose restart app"
echo "   docker compose restart db"
echo ""
echo "5. 🏗️ Problemas de compilación:"
echo "   - Error 'yaml.h not found': ✅ Ya solucionado en Dockerfile"
echo "   - Error 'Missing secret_key_base': ✅ Ya solucionado en Dockerfile"
echo "   - Error 'active_admin.css not present': ✅ Ya solucionado en assets pipeline"
echo "   - Error 'undefined method delete for Symbol': ✅ Ya solucionado en status_tag"
echo "   - Error 'relation active_admin_comments does not exist': ✅ Ya solucionado (comentarios deshabilitados)"
echo "   - Error 'verify_authenticity_token has not been defined': ✅ Ya solucionado (ActionController::Base)"
echo "   - Error 'undefined method id for nil:NilClass': ✅ Ya solucionado (verificación de autenticación)"
echo "   - Error de gemas: Elimina Gemfile.lock y reconstruye"
echo ""
echo "6. 🌐 Problemas de red:"
echo "   - Puerto 3000 ocupado: docker compose down y reinicia"
echo "   - Puerto 5432 ocupado: Para PostgreSQL local"
echo ""

echo -e "${GREEN}=== 🎯 URLS IMPORTANTES ===${NC}"
echo "• API: http://localhost:3000"
echo "• Admin Panel: http://localhost:3000/admin"
echo "• API Info: http://localhost:3000/api/info"
echo "• Health Check: http://localhost:3000/up"
echo ""

echo -e "${GREEN}=== 🔑 CREDENCIALES DEFAULT ===${NC}"
echo "• Admin Email: admin@rails-baas.com"
echo "• Admin Password: password123"
echo "• PostgreSQL User: postgres"
echo "• PostgreSQL Password: password"
echo ""

echo "🔍 Diagnóstico completado!"
