#!/usr/bin/env bash
# Descarga la Fábrica MINDTUBE (By Thalia Ruiz) en la carpeta donde estás. Funciona en Mac, Linux y Windows (Git Bash).
# Uso (lo ejecuta Claude):  curl -fsSL https://raw.githubusercontent.com/thaliaruizmc/fabrica-mindtube/main/instalar-en-linea/descargar.sh | bash
# Prueba sin internet:  FABRICA_ZIP=/ruta/FabricaMINDTUBE.zip bash descargar.sh
set -e
REPO="thaliaruizmc/fabrica-mindtube"
ZIP="${FABRICA_ZIP:-https://github.com/$REPO/releases/latest/download/FabricaMINDTUBE.zip}"

if [ -f "herramientas/fabrica.py" ]; then
  echo "Aquí ya está la Fábrica. Para ponerla al día: python herramientas/fabrica.py actualizar"
  exit 0
fi
if [ -n "$(ls -A . 2>/dev/null | grep -v '^\.claude$')" ]; then
  echo "✗ Esta carpeta no está vacía. Crea una carpeta nueva y vacía (por ejemplo «FabricaMINDTUBE» en Documentos), ábrela en Claude y vuelve a empezar."
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Descargando la Fábrica MINDTUBE (unos 400 MB, un momento)…"
case "$ZIP" in
  http*) curl -fL --retry 3 -o "$TMP/f.zip" "$ZIP" ;;
  *) cp "$ZIP" "$TMP/f.zip" ;;
esac
[ "$(wc -c < "$TMP/f.zip")" -gt 1000000 ] || { echo "✗ La descarga llegó incompleta. Vuelve a intentarlo."; exit 1; }

echo "Abriendo el paquete…"
# bsdtar (Windows 10+ y Mac) respeta los nombres con tilde; el unzip de Git Bash los estropea
if [ -x /c/Windows/System32/tar.exe ]; then
  /c/Windows/System32/tar.exe -xf "$TMP/f.zip"
elif [ "$(uname -s)" = "Darwin" ]; then
  tar -xf "$TMP/f.zip"
elif command -v unzip >/dev/null 2>&1; then
  unzip -q -o "$TMP/f.zip" -d .
else
  tar -xf "$TMP/f.zip"
fi
[ -f "herramientas/fabrica.py" ] || { echo "✗ El paquete no se abrió bien."; exit 1; }
echo "✓ Fábrica MINDTUBE descargada (versión $(cat VERSION.txt 2>/dev/null || echo ?)). Ahora sigue las instrucciones de CLAUDE.md para instalarla."
