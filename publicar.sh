#!/bin/bash

file_ics=~/Dropbox/Apps/Orgzly/agenda.ics
file2_ics=~/0n-git/bullettoical/farmacia-seminarios.ics
file3_ics=~/0n-git/bullettoical/farmacia-talleres.ics


# Copiar el archivo al repositorio local
cp "$file_ics" .
cp "$file2_ics" .
cp "$file3_ics" .

# Verificar si la red WiFi es eduroam
current_wifi=$(iwgetid -r)
if [[ $current_wifi == "eduroam" ]]; then
    echo "No se puede realizar el push desde la red WiFi 'eduroam'. Cambia a otra red para poder hacerlo."
    exit 1
fi

# Obtener la hora y el minuto actual
current_time=$(date +"%H:%M")

# Realizar el commit con la hora y el minuto actual
commit_message="Incorporar nueva agenda a las $current_time"
git add agenda.ics farmacia-seminarios.ics farmacia-talleres.ics
git commit -m "$commit_message"

# Hacer push al repositorio remoto
git push origin main
