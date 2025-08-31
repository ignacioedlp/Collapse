# Controlador para operaciones CRUD de usuarios
class Api::UsersController < Api::BaseController
  before_action :set_user, only: [:show, :update, :destroy]
  
  # GET /api/users
  # Listar todos los usuarios (con paginación)
  def index
    # Parámetros de paginación
    page = params[:page] || 1
    per_page = [params[:per_page]&.to_i || 10, 100].min # Máximo 100 por página
    
    # Parámetros de filtrado
    users = User.all
    
    # Filtrar por estado de confirmación
    if params[:confirmed].present?
      users = params[:confirmed] == 'true' ? users.confirmed : users.unconfirmed
    end
    
    # Filtrar por proveedor
    if params[:provider].present?
      case params[:provider]
      when 'google'
        users = users.google_users
      when 'local'
        users = users.local_users
      end
    end
    
    # Buscar por email o nombre
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      users = users.where(
        "email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
        search_term, search_term, search_term
      )
    end
    
    # Ordenamiento
    order_by = params[:order_by] || 'created_at'
    order_direction = params[:order_direction] || 'desc'
    
    # Validar parámetros de ordenamiento
    allowed_order_fields = %w[created_at updated_at email first_name last_name]
    order_by = 'created_at' unless allowed_order_fields.include?(order_by)
    order_direction = 'desc' unless %w[asc desc].include?(order_direction)
    
    users = users.order("#{order_by} #{order_direction}")
    
    # Paginación manual (en un proyecto real usarías una gema como Kaminari)
    total_count = users.count
    offset = (page.to_i - 1) * per_page
    users = users.limit(per_page).offset(offset)
    
    render_success({
      users: users.map { |user| user_response(user) },
      pagination: {
        current_page: page.to_i,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    })
  end
  
  # GET /api/users/:id
  # Mostrar un usuario específico
  def show
    render_success({
      user: user_response(@user)
    })
  end
  
  # PUT /api/users/:id
  # Actualizar un usuario (solo admin o el propio usuario)
  def update
    # Verificar permisos: solo el propio usuario puede editarse
    # (En un futuro podrías agregar roles de admin)
    unless @user == current_user
      return render_error(
        'No tienes permisos para editar este usuario',
        :forbidden
      )
    end
    
    if @user.update(user_update_params)
      render_success({
        user: user_response(@user)
      }, 'Usuario actualizado exitosamente')
    else
      render_error(
        'Error al actualizar usuario',
        :unprocessable_entity,
        @user.errors.full_messages
      )
    end
  end
  
  # DELETE /api/users/:id
  # Eliminar un usuario (solo admin o el propio usuario)
  def destroy
    # Verificar permisos: solo el propio usuario puede eliminarse
    unless @user == current_user
      return render_error(
        'No tienes permisos para eliminar este usuario',
        :forbidden
      )
    end
    
    if @user.destroy
      render_success({}, 'Usuario eliminado exitosamente')
    else
      render_error(
        'Error al eliminar usuario',
        :unprocessable_entity,
        @user.errors.full_messages
      )
    end
  end
  
  private
  
  # Buscar usuario por ID
  def set_user
    @user = User.find(params[:id])
  end
  
  # Parámetros permitidos para actualización
  def user_update_params
    params.require(:user).permit(:first_name, :last_name)
  end
  
  # Formato de respuesta del usuario
  def user_response(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      confirmed: user.confirmed?,
      google_user: user.google_user?,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
