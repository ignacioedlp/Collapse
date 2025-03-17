class Api::V1::ProfileController < Api::V1::ApiController
    after_action :verify_authorized

    # GET /api/v1/profile
    def show
        authorize current_user
        render json: UserSerializer.new(current_user).serializable_hash.to_json
    end

    # PUT /api/v1/profile
    def update
        authorize current_user
        if current_user.update(user_params)
            render json: UserSerializer.new(current_user).serializable_hash
        else
            render json: { errors: current_user.errors }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:name, :email)
    end
end
