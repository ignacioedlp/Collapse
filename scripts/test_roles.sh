#!/bin/bash

# Script para probar roles y permisos
echo "🎭 Probando Roles y Permisos..."

BASE_URL="http://localhost:3000"

echo ""
echo "1. 🔐 Probando login con usuario admin..."

# Login con usuario admin
admin_response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario1@ejemplo.com",
    "password": "password123"
  }')

admin_http_code="${admin_response: -3}"
admin_body="${admin_response%???}"

if [ "$admin_http_code" = "200" ]; then
  echo "✅ Login exitoso"
  admin_token=$(echo "$admin_body" | jq -r '.data.token // empty')
  
  if [ -n "$admin_token" ] && [ "$admin_token" != "null" ]; then
    echo "✅ Token JWT obtenido"
    
    echo ""
    echo "2. 👤 Probando endpoint /api/v1/me con admin..."
    me_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/v1/me" \
      -H "Authorization: Bearer $admin_token")
    
    me_http_code="${me_response: -3}"
    me_body="${me_response%???}"
    
    if [ "$me_http_code" = "200" ]; then
      echo "✅ Endpoint /api/v1/me accesible"
      user_roles=$(echo "$me_body" | jq -r '.data.user.roles // []')
      echo "   Roles del usuario: $user_roles"
    else
      echo "❌ Error en /api/v1/me: $me_http_code"
    fi
    
  else
    echo "❌ No se pudo obtener token JWT"
  fi
else
  echo "❌ Error en login: $admin_http_code"
  echo "   Respuesta: $admin_body"
fi

echo ""
echo "3. 🔐 Probando login con usuario normal..."

# Login con usuario normal
user_response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario2@ejemplo.com",
    "password": "password123"
  }')

user_http_code="${user_response: -3}"
user_body="${user_response%???}"

if [ "$user_http_code" = "200" ]; then
  echo "✅ Login exitoso"
  user_token=$(echo "$user_body" | jq -r '.data.token // empty')
  
  if [ -n "$user_token" ] && [ "$user_token" != "null" ]; then
    echo "✅ Token JWT obtenido"
    
    echo ""
    echo "4. 👤 Probando endpoint /api/v1/me con usuario normal..."
    user_me_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/v1/me" \
      -H "Authorization: Bearer $user_token")
    
    user_me_http_code="${user_me_response: -3}"
    user_me_body="${user_me_response%???}"
    
    if [ "$user_me_http_code" = "200" ]; then
      echo "✅ Endpoint /api/v1/me accesible"
      normal_user_roles=$(echo "$user_me_body" | jq -r '.data.user.roles // []')
      echo "   Roles del usuario: $normal_user_roles"
    else
      echo "❌ Error en /api/v1/me: $user_me_http_code"
    fi
    
  else
    echo "❌ No se pudo obtener token JWT"
  fi
else
  echo "❌ Error en login: $user_http_code"
  echo "   Respuesta: $user_body"
fi

echo ""
echo "5. 🚫 Probando acceso sin token..."
no_token_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/v1/me")
no_token_http_code="${no_token_response: -3}"

if [ "$no_token_http_code" = "401" ]; then
  echo "✅ Acceso correctamente bloqueado sin token"
else
  echo "❌ Error: debería bloquear acceso sin token (código 401)"
fi

echo ""
echo "🎉 Pruebas de Roles y Permisos completadas!"
echo ""
echo "📋 Resumen de roles configurados:"
echo "   - admin: Acceso completo al sistema"
echo "   - moderator: Gestión de usuarios y contenido"
echo "   - user: Acceso básico (por defecto)"
echo ""
echo "🔧 Para gestionar roles:"
echo "   - Panel Admin: http://localhost:3000/admin"
echo "   - Editar usuarios y asignar roles"
echo "   - Los roles se aplican automáticamente en la API"
