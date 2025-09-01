# Archivo de seeds para poblar la base de datos con datos iniciales

puts "🌱 Iniciando seeds..."

# Crear usuario administrador para ActiveAdmin
puts "👤 Creando usuario administrador..."

admin = AdminUser.find_or_create_by(email: 'admin@rails-baas.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.active = true
end

if admin.persisted?
  puts "✅ Usuario administrador creado:"
  puts "   Email: admin@rails-baas.com"
  puts "   Password: password123"
  puts "   URL: http://localhost:3000/admin"
else
  puts "❌ Error al crear usuario administrador:"
  admin.errors.full_messages.each { |msg| puts "   - #{msg}" }
end

# Crear roles por defecto
puts "\n🎭 Creando roles del sistema..."

roles = ['owner', 'moderator', 'user']
roles_created = 0

roles.each do |role_name|
  role = Role.find_or_create_by(name: role_name)
  if role.persisted?
    roles_created += 1
    puts "   - Rol '#{role_name}' creado"
  else
    puts "   ❌ Error al crear rol '#{role_name}': #{role.errors.full_messages.join(', ')}"
  end
end

puts "✅ #{roles_created} roles creados"

# Crear algunos usuarios de prueba
puts "\n👥 Creando usuarios de prueba..."

users_data = [
  {
    email: 'usuario1@ejemplo.com',
    password: 'password123',
    first_name: 'Juan',
    last_name: 'Pérez',
    confirmed_at: Time.current
  },
  {
    email: 'usuario2@ejemplo.com',
    password: 'password123',
    first_name: 'María',
    last_name: 'García',
    confirmed_at: Time.current
  },
  {
    email: 'usuario3@ejemplo.com',
    password: 'password123',
    first_name: 'Carlos',
    last_name: 'López',
    confirmed_at: nil # Usuario sin confirmar
  }
]

users_created = 0
users_data.each do |user_data|
  user = User.find_or_create_by(email: user_data[:email]) do |u|
    u.password = user_data[:password]
    u.first_name = user_data[:first_name]
    u.last_name = user_data[:last_name]
    u.confirmed_at = user_data[:confirmed_at]
  end
  
  if user.persisted?
    users_created += 1
    status = user.confirmed? ? "✅ Confirmado" : "⏳ Pendiente"
    puts "   - #{user.full_name} (#{user.email}) #{status}"
  end
end

puts "✅ #{users_created} usuarios de prueba creados"

# Mostrar estadísticas finales
puts "\n📊 Estadísticas finales:"
puts "   - Administradores: #{AdminUser.count}"
puts "   - Usuarios totales: #{User.count}"
puts "   - Usuarios confirmados: #{User.confirmed.count}"
puts "   - Usuarios sin confirmar: #{User.unconfirmed.count}"

# Asignar rol de owner al primer usuario si existe (opcional)
if User.count > 0 && Role.exists_by_name?('owner')
  first_user = User.first
  owner_role = Role.find_by(name: 'owner')
  unless first_user.has_role?(:owner)
    first_user.add_role(owner_role)
    puts "✅ Rol de owner asignado al usuario: #{first_user.email}"
  else
    puts "✅ Usuario #{first_user.email} ya tiene rol de owner"
  end
end

# Verificar que todos los usuarios tienen al menos el rol 'user'
puts "\n🔍 Verificando roles de usuarios..."
User.all.each do |user|
  if user.roles.empty?
    puts "⚠️  Usuario #{user.email} no tiene roles asignados"
  else
    role_names = user.roles.pluck(:name).join(', ')
    puts "✅ Usuario #{user.email} tiene roles: #{role_names}"
  end
end

puts "\n🎉 Seeds completados exitosamente!"
puts "\n📝 Información importante:"
puts "   - Panel de administración: http://localhost:3000/admin"
puts "   - Credenciales admin: admin@rails-baas.com / password123"
puts "   - API Info: http://localhost:3000/api/info"
puts "   - Para probar la API, usa los usuarios de prueba creados"

puts "\n🚀 ¡Tu BaaS está listo para usar!"