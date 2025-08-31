#!/bin/bash

# Script para probar los endpoints de la API
echo "🧪 Probando endpoints de la API..."

BASE_URL="http://localhost:3000"

echo ""
echo "1. 🔍 Probando endpoint de información del sistema..."
curl -s -X GET "$BASE_URL/api/info" | jq '.'

echo ""
echo "2. 📝 Probando registro de usuario..."
curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "first_name": "Test",
      "last_name": "User"
    }
  }' | jq '.'

echo ""
echo "3. 🔐 Probando login de usuario..."
curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }' | jq '.'

echo ""
echo "✅ Pruebas completadas!"
