#!/bin/bash

# Script para verificar que la API esté funcionando correctamente
echo "🔍 Verificando configuración de la API..."

BASE_URL="http://localhost:3000"

echo ""
echo "1. 🔍 Probando endpoint de información del sistema..."
response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/info")
http_code="${response: -3}"
body="${response%???}"

echo "HTTP Code: $http_code"
echo "Response:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"

if [ "$http_code" = "200" ]; then
    echo "✅ Endpoint /api/info funcionando correctamente"
else
    echo "❌ Endpoint /api/info falló con código $http_code"
fi

echo ""
echo "2. 📝 Probando registro de usuario..."
response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "first_name": "Test",
      "last_name": "User"
    }
  }')
http_code="${response: -3}"
body="${response%???}"

echo "HTTP Code: $http_code"
echo "Response:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"

if [ "$http_code" = "201" ]; then
    echo "✅ Endpoint /api/auth/register funcionando correctamente"
    
    # Extraer token si el registro fue exitoso
    token=$(echo "$body" | jq -r '.data.token // empty' 2>/dev/null)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
        echo "✅ Token JWT generado correctamente"
        
        echo ""
        echo "3. 👤 Probando endpoint /api/auth/me con token..."
        me_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/auth/me" \
          -H "Authorization: Bearer $token")
        me_http_code="${me_response: -3}"
        me_body="${me_response%???}"
        
        echo "HTTP Code: $me_http_code"
        if [ "$me_http_code" = "200" ]; then
            echo "✅ Endpoint /api/auth/me funcionando correctamente"
        else
            echo "❌ Endpoint /api/auth/me falló con código $me_http_code"
        fi
        
        echo ""
        echo "4. 🚫 Probando /api/auth/me sin token (debe fallar)..."
        no_token_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/auth/me")
        no_token_http_code="${no_token_response: -3}"
        
        echo "HTTP Code: $no_token_http_code"
        if [ "$no_token_http_code" = "401" ]; then
            echo "✅ Endpoint /api/auth/me correctamente rechaza requests sin token"
        else
            echo "❌ Endpoint /api/auth/me debería rechazar requests sin token (código 401)"
        fi
    fi
else
    echo "❌ Endpoint /api/auth/register falló con código $http_code"
fi

echo ""
echo "5. 🔐 Probando login de usuario..."
login_response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')
login_http_code="${login_response: -3}"
login_body="${login_response%???}"

echo "HTTP Code: $login_http_code"
if [ "$login_http_code" = "200" ]; then
    echo "✅ Endpoint /api/auth/login funcionando correctamente"
else
    echo "❌ Endpoint /api/auth/login falló con código $login_http_code"
fi

echo ""
echo "🎉 Verificación de la API completada!"
