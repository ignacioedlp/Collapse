#!/bin/bash

# Script para probar que Swagger esté funcionando correctamente
echo "📚 Probando documentación de Swagger..."

BASE_URL="http://localhost:3000"

echo ""
echo "1. 🔍 Probando endpoint de Swagger YAML..."
yaml_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/swagger/v1/swagger.yaml")
yaml_http_code="${yaml_response: -3}"
yaml_body="${yaml_response%???}"

echo "HTTP Code: $yaml_http_code"
if [ "$yaml_http_code" = "200" ]; then
    echo "✅ Swagger YAML servido correctamente"
    
    # Verificar que el YAML es válido (básico)
    if echo "$yaml_body" | grep -q "openapi:"; then
        echo "✅ Swagger YAML es válido"
        
        # Extraer información básica
        title=$(echo "$yaml_body" | grep "title:" | head -1 | sed 's/.*title: //' | tr -d '"')
        version=$(echo "$yaml_body" | grep "version:" | head -1 | sed 's/.*version: //' | tr -d '"')
        paths_count=$(echo "$yaml_body" | grep "^- /" | wc -l)
        
        echo "📋 Información de la API:"
        echo "   - Título: $title"
        echo "   - Versión: $version"
        echo "   - Endpoints documentados: $paths_count"
    else
        echo "❌ Swagger YAML no es válido"
    fi
else
    echo "❌ Error al obtener Swagger YAML (código $yaml_http_code)"
fi

echo ""
echo "2. 🔍 Probando endpoint de Swagger JSON..."
response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/swagger/v1/swagger.json")
http_code="${response: -3}"
body="${response%???}"

echo "HTTP Code: $http_code"
if [ "$http_code" = "200" ]; then
    echo "✅ Swagger JSON servido correctamente"
    
    # Verificar que el JSON es válido
    if echo "$body" | jq . > /dev/null 2>&1; then
        echo "✅ Swagger JSON es válido"
    else
        echo "❌ Swagger JSON no es válido"
    fi
else
    echo "❌ Error al obtener Swagger JSON (código $http_code)"
fi

echo ""
echo "3. 🌐 Probando Swagger UI..."
ui_response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/api-docs")
ui_http_code="${ui_response: -3}"

echo "HTTP Code: $ui_http_code"
if [ "$ui_http_code" = "200" ]; then
    echo "✅ Swagger UI accesible correctamente"
    echo "🌐 Puedes acceder a la documentación en: $BASE_URL/api-docs"
else
    echo "❌ Error al acceder a Swagger UI (código $ui_http_code)"
fi

echo ""
echo "4. 🔗 Verificando enlaces en el dashboard..."
echo "   - Swagger UI: $BASE_URL/api-docs"
echo "   - Swagger YAML: $BASE_URL/swagger/v1/swagger.yaml"
echo "   - Swagger JSON: $BASE_URL/swagger/v1/swagger.json"
echo "   - API Info: $BASE_URL/api/info"

echo ""
echo "🎉 Pruebas de Swagger completadas!"
echo ""
echo "📚 Para acceder a la documentación interactiva:"
echo "   🌐 $BASE_URL/api-docs"
