# Dockerfile para Rails BaaS
FROM ruby:3.1-slim

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    libyaml-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    nodejs \
    npm \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar dockerize para esperar a que PostgreSQL esté listo
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar -C /usr/local/bin -xzv

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY Gemfile* ./

# Instalar gemas (sin modo frozen para permitir actualizaciones)
RUN bundle config --global silence_root_warning 1 && \
    bundle install --jobs 4 --retry 3 --verbose

# Copiar el código de la aplicación
COPY . .

# Crear directorios necesarios
RUN mkdir -p tmp/pids && \
    mkdir -p storage

# Precompilar assets para ActiveAdmin
# Usamos variables temporales solo para la compilación
RUN SECRET_KEY_BASE=dummy_key_for_assets_precompile \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    bundle exec rails assets:precompile --trace

# Exponer puerto
EXPOSE 3000

# Crear script de inicio
RUN echo '#!/bin/bash\n\
    set -e\n\
    \n\
    # Función para logging\n\
    log() {\n\
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1"\n\
    }\n\
    \n\
    # Verificar variables de entorno\n\
    if [ -z "$SECRET_KEY_BASE" ]; then\n\
    log "Generando SECRET_KEY_BASE temporal..."\n\
    export SECRET_KEY_BASE=$(bundle exec rails secret)\n\
    fi\n\
    \n\
    # Preparar base de datos\n\
    log "Preparando base de datos..."\n\
    bundle exec rails db:create 2>/dev/null || log "Base de datos ya existe"\n\
    bundle exec rails db:migrate\n\
    \n\
    # Ejecutar seeds si es necesario\n\
    if [ "$RAILS_ENV" != "production" ]; then\n\
    log "Ejecutando seeds..."\n\
    bundle exec rails db:seed\n\
    fi\n\
    \n\
    # Iniciar servidor\n\
    log "Iniciando servidor Rails en puerto 3000..."\n\
    bundle exec rails server -b 0.0.0.0 -p 3000' > /app/docker-entrypoint.sh

RUN chmod +x /app/docker-entrypoint.sh

# Comando por defecto
CMD ["/app/docker-entrypoint.sh"]