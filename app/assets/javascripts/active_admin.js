//= require active_admin/base

// JavaScript personalizado para Rails BaaS Admin
$(document).ready(function () {
  console.log('Rails BaaS ActiveAdmin loaded');

  // Agregar funcionalidades personalizadas aquí

  // Ejemplo: Confirmar eliminaciones
  $('.delete_link').on('click', function (e) {
    if (!confirm('¿Estás seguro de que quieres eliminar este elemento?')) {
      e.preventDefault();
      return false;
    }
  });

  // Ejemplo: Auto-refresh para el dashboard cada 30 segundos
  if ($('body').hasClass('admin_dashboard')) {
    setInterval(function () {
      // Solo refrescar si no hay modales abiertos
      if (!$('.ui-dialog').is(':visible')) {
        location.reload();
      }
    }, 30000);
  }

  // Mejorar UX con tooltips para botones de acción
  $('[title]').tooltip();
});
