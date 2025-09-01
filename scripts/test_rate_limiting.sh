#!/bin/bash

# Script para probar el rate limiting
echo "🔒 Probando Rate Limiting..."

BASE_URL="http://localhost:3000"

echo ""
echo "1. 🔍 Probando rate limiting en registro..."
echo "   Intentando registrar usuarios múltiples veces..."

for i in {1..7}; do
  echo "   Intento $i/7..."
  response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"user\": {
        \"email\": \"test$i@example.com\",
        \"password\": \"password123\",
        \"password_confirmation\": \"password123\",
        \"first_name\": \"Test$i\",
        \"last_name\": \"User\"
      }
    }")
  
  http_code="${response: -3}"
  body="${response%???}"
  
  if [ "$http_code" = "429" ]; then
    echo "   ✅ Rate limit activado correctamente en intento $i"
    echo "   Respuesta: $(echo "$body" | jq -r '.message // "Rate limit exceeded"')"
    break
  elif [ "$http_code" = "201" ]; then
    echo "   ✅ Registro exitoso en intento $i"
  else
    echo "   ❌ Error inesperado: $http_code"
  fi
  
  sleep 1
done

echo ""
echo "2. 🔐 Probando rate limiting en login..."
echo "   Intentando hacer login múltiples veces..."

for i in {1..12}; do
  echo "   Intento $i/12..."
  response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"usuario1@ejemplo.com\",
      \"password\": \"wrongpassword\"
    }")
  
  http_code="${response: -3}"
  body="${response%???}"
  
  if [ "$http_code" = "429" ]; then
    echo "   ✅ Rate limit activado correctamente en intento $i"
    echo "   Respuesta: $(echo "$body" | jq -r '.message // "Rate limit exceeded"')"
    break
  elif [ "$http_code" = "401" ]; then
    echo "   ✅ Login fallido correctamente en intento $i (credenciales incorrectas)"
  else
    echo "   ❌ Error inesperado: $http_code"
  fi
  
  sleep 1
done

echo ""
echo "3. 🌐 Probando rate limiting general de API..."
echo "   Haciendo múltiples requests a /api/info..."

for i in {1..100}; do
  if [ $((i % 20)) -eq 0 ]; then
    echo "   Request $i/100..."
  fi
  
  response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api/info")
  http_code="${response: -3}"
  
  if [ "$http_code" = "429" ]; then
    echo "   ✅ Rate limit general activado en request $i"
    break
  elif [ "$http_code" = "200" ]; then
    # Continuar
    :
  else
    echo "   ❌ Error inesperado: $http_code"
    break
  fi
  
  sleep 0.1
done

echo ""
echo "🎉 Pruebas de Rate Limiting completadas!"
echo ""
echo "📋 Resumen de límites configurados:"
echo "   - Registro: 5 intentos por hora por IP"
echo "   - Login: 10 intentos por hora por IP"
echo "   - Google OAuth: 20 intentos por hora por IP"
echo "   - API general: 1000 requests por hora por IP"
echo "   - Usuario autenticado: 5000 requests por hora"
echo "   - Escritura por usuario: 1000 requests por hora"
