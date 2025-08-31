# Controlador para operaciones CRUD de usuarios
class Api::V1::MeController < Api::V1::BaseController  
  # GET /api/me/show
  # Obtener información del usuario actual
  def show
    render_success({
      user: user_response(current_user)
    }, 'Información del usuario obtenida')
  end
  
  # PUT /api/me/edit
  # Actualizar perfil del usuario
  def edit
    if current_user.update(user_update_params)
      render_success({
        user: user_response(current_user)
      }, 'Perfil actualizado exitosamente')
    else
      render_error(
        'Error al actualizar perfil',
        :unprocessable_entity,
        current_user.errors.full_messages
      )
    end
  end

  # Parámetros permitidos para actualización de perfil
  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
