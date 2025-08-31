// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
//= require_tree .
//= require_self

// JavaScript básico para Rails BaaS
console.log('Rails BaaS - Backend as a Service loaded');

// Funciones de utilidad para el admin panel
window.RailsBaaS = {
  version: '1.0.0',

  // Función para mostrar mensajes flash
  showFlash: function (message, type) {
    type = type || 'info';
    console.log(`[${type.toUpperCase()}] ${message}`);
  },

  // Función para hacer requests AJAX simples
  request: function (url, options) {
    options = options || {};
    const defaults = {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    };

    return fetch(url, Object.assign(defaults, options))
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      });
  }
};

// Auto-inicialización cuando el DOM está listo
document.addEventListener('DOMContentLoaded', function () {
  console.log('Rails BaaS Admin Panel ready');
});
