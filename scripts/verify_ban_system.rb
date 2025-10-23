#!/usr/bin/env ruby
# Script para verificar que el sistema de baneos funciona correctamente

puts "=== Verificando Sistema de Baneos ==="

# Verificar que las tablas existen
puts "\nVerificando tablas:"
puts "- Usuarios: #{User.count}"
puts "- Admins: #{AdminUser.count}" 
puts "- BanLogs: #{BanLog.count}"

# Probar un baneo simple
if User.not_banned.any? && AdminUser.any?
  user = User.not_banned.first
  admin = AdminUser.first
  
  puts "\n=== Probando baneo básico ==="
  puts "Usuario de prueba: #{user.full_name} (#{user.email})"
  puts "Admin de prueba: #{admin.email}"
  
  # Probar baneo
  result = user.ban!(
    reason: "Prueba del sistema de baneos", 
    admin_user: admin,
    until_date: 1.hour.from_now
  )
  
  if result
    puts "✓ Baneo exitoso"
    puts "Estado: #{user.ban_status}"
    puts "BanLogs creados: #{user.ban_logs.count}"
  else
    puts "✗ Error en baneo"
  end
  
  # Probar desbaneo
  if user.banned?
    puts "\n=== Probando desbaneo ==="
    unban_result = user.unban!(admin_user: admin)
    
    if unban_result
      puts "✓ Desbaneo exitoso"
      puts "Estado: #{user.banned? ? 'Baneado' : 'Activo'}"
    else
      puts "✗ Error en desbaneo"
    end
  end
else
  puts "\n❌ No hay usuarios o admins suficientes para probar"
end

puts "\n=== Verificación completada ==="