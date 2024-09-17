#!/bin/bash

# Constante de configuración
FILE_TO_MONITOR="/home/victor/Dropbox/Apps/Orgzly/agenda.ics"  # Archivo que quieres monitorear
SERVICE_NAME="vgpAgendaICS"         # Nombre del servicio y del path unit
SCRIPT_TO_EXECUTE="publica-azure"   # Script a ejecutar cuando se detecte un cambio

# Verificación de root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor ejecuta este script como root o con sudo"
  exit 1
fi

# Verificar si el archivo a monitorear existe
if [ ! -f "$FILE_TO_MONITOR" ]; then
  echo "El archivo $FILE_TO_MONITOR no existe. Por favor verifica la ruta."
  exit 1
fi

# Obtener el nombre del usuario actual
USER=$(logname)

# Crear el archivo de servicio
echo "Creando el archivo de servicio systemd: /etc/systemd/system/${SERVICE_NAME}.service"
cat <<EOL > /etc/systemd/system/${SERVICE_NAME}.service
[Unit]
Description=Servicio activado por cambios en ${FILE_TO_MONITOR}

[Service]
User=${USER}
ExecStart=${SCRIPT_TO_EXECUTE}
# Establecer el HOME del usuario para que sea el correcto
Environment=HOME=/home/${USER}
Environment=USER=${USER}
WorkingDirectory=/home/${USER}
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

# Crear el archivo de path unit
echo "Creando el archivo de path unit systemd: /etc/systemd/system/${SERVICE_NAME}.path"
cat <<EOL > /etc/systemd/system/${SERVICE_NAME}.path
[Unit]
Description=Monitoreo de cambios en ${FILE_TO_MONITOR}

[Path]
PathModified=${FILE_TO_MONITOR}

[Install]
WantedBy=multi-user.target
EOL

# Recargar los daemons de systemd
echo "Recargando los demonios de systemd para aplicar los cambios..."
systemctl daemon-reload

# Habilitar y activar el Path Unit
echo "Habilitando y activando el monitoreo del archivo..."
systemctl enable --now ${SERVICE_NAME}.path

# Confirmación final
echo "El monitoreo del archivo ${FILE_TO_MONITOR} está habilitado para el usuario ${USER}."
echo "Cada vez que se modifique, se ejecutará el script: ${SCRIPT_TO_EXECUTE}"
echo "La salida del script se registrará en los logs de systemd (journal)."
