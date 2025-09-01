module ApplicationHelper
  # Helpers para la aplicación Rails BaaS
  # Estos helpers están disponibles en todas las vistas

  def page_title(title = nil)
    if title
      content_for(:title, title)
      title
    else
      content_for?(:title) ? content_for(:title) : 'Rails BaaS'
    end
  end

  def flash_class(level)
    case level.to_sym
    when :notice then 'alert alert-info'
    when :success then 'alert alert-success'
    when :error then 'alert alert-danger'
    when :alert then 'alert alert-warning'
    else 'alert alert-info'
    end
  end
end
