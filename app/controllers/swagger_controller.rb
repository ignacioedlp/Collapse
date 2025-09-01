class SwaggerController < ApplicationController
  def index
    render json: File.read(Rails.root.join('swagger', 'v1', 'swagger.json'))
  end

  def yaml
    render plain: File.read(Rails.root.join('swagger', 'v1', 'swagger.yaml')), content_type: 'text/yaml'
  end
end
