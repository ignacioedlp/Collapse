Rswag::Ui.configure do |c|

  # List the Swagger endpoints that you want to be documented through the
  # swagger-ui. The first parameter is the path (absolute or relative to the UI
  # host) to the corresponding endpoint and the second is a title that will be
  # displayed in the document selector.
  # NOTE: If you're using rspec-api to expose Swagger files
  # (under openapi_root) as JSON or YAML endpoints, then the list below should
  # correspond to the relative paths for those endpoints.

  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'

  # UI configuration options
  c.config_object['defaultModelsExpandDepth'] = 2
  c.config_object['defaultModelExpandDepth'] = 2
  c.config_object['defaultModelRendering'] = 'model'
  c.config_object['displayRequestDuration'] = true
  c.config_object['docExpansion'] = 'list'
  c.config_object['filter'] = true
  c.config_object['showExtensions'] = true
  c.config_object['showCommonExtensions'] = true
  c.config_object['tryItOutEnabled'] = true
end
