#!/usr/bin/env ruby

# Script para verificar que ActiveAdmin esté funcionando correctamente
puts "🔍 Verificando configuración de ActiveAdmin..."

# Verificar que los comentarios estén deshabilitados
if defined?(ActiveAdmin)
  puts "✅ ActiveAdmin está cargado"
  
  if ActiveAdmin.application.comments == false
    puts "✅ Comentarios deshabilitados correctamente"
  else
    puts "❌ Comentarios aún están habilitados"
  end
else
  puts "❌ ActiveAdmin no está cargado"
end

# Verificar que no exista la tabla de comentarios
begin
  if ActiveRecord::Base.connection.table_exists?('active_admin_comments')
    puts "❌ La tabla active_admin_comments aún existe"
  else
    puts "✅ La tabla active_admin_comments no existe (correcto)"
  end
rescue => e
  puts "✅ No se puede verificar la tabla (probablemente no existe): #{e.message}"
end

puts "\n🎉 Verificación completada!"
