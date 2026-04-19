#!/bin/bash

# Script de construcción para Cloudflare Pages
# Descarga Flutter, lo añade al path y construye la versión web.

echo "--- Descargando Flutter ---"
git clone https://github.com/flutter/flutter.git -b stable

echo "--- Configurando PATH ---"
export PATH="$PATH:`pwd`/flutter/bin"

echo "--- Verificando instalación ---"
flutter doctor

echo "--- Construyendo aplicación Web ---"
flutter build web --release --no-tree-shake-icons

echo "--- Construcción finalizada con éxito ---"
