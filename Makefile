#####OJO NO LO HE PROBADO########
# Nombre del paquete
PACKAGE_NAME = bullettoical
VERSION = 1.0.0
ARCH = all
PYTHON_SCRIPT = subir_blob.py
CONFIG_DIR = ~/.vgp/bullettoical/
BIN_DIR = /usr/local/bin/
INFO_DIR = /usr/share/info/

# Directorios para la estructura de paquetes Debian
BUILD_DIR = build
DEB_DIR = $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)
DEB_BIN_DIR = $(DEB_DIR)/usr/local/bin
DEB_DOC_DIR = $(DEB_DIR)/usr/share/doc/$(PACKAGE_NAME)
DEB_INFO_DIR = $(DEB_DIR)/usr/share/info

# Nombre del archivo .deb final
DEB_PACKAGE = $(PACKAGE_NAME)_$(VERSION)_$(ARCH).deb

.PHONY: all clean build deb install

# Regla principal
all: clean build deb

# Crear el binario de Python con PyInstaller
build:
	@echo "=== Creando el binario de Python ==="
	pyinstaller --onefile $(PYTHON_SCRIPT)
	@echo "=== Preparando la estructura de carpetas del paquete Debian ==="
	mkdir -p $(DEB_BIN_DIR)
	mkdir -p $(DEB_DOC_DIR)
	mkdir -p $(DEB_INFO_DIR)
	@echo "=== Copiando binario al directorio de destino ==="
	cp dist/$(PACKAGE_NAME) $(DEB_BIN_DIR)/$(PACKAGE_NAME)
	@echo "=== Copiando documentación ==="
	cp -r doc/* $(DEB_DOC_DIR)/
	@echo "=== Copiando archivo info ==="
	cp $(PACKAGE_NAME).info $(DEB_INFO_DIR)

# Crear el paquete Debian
deb: build
	@echo "=== Generando el archivo control ==="
	mkdir -p $(DEB_DIR)/DEBIAN
	echo "Package: $(PACKAGE_NAME)" > $(DEB_DIR)/DEBIAN/control
	echo "Version: $(VERSION)" >> $(DEB_DIR)/DEBIAN/control
	echo "Section: utils" >> $(DEB_DIR)/DEBIAN/control
	echo "Priority: optional" >> $(DEB_DIR)/DEBIAN/control
	echo "Architecture: $(ARCH)" >> $(DEB_DIR)/DEBIAN/control
	echo "Maintainer: Tu Nombre <tuemail@dominio.com>" >> $(DEB_DIR)/DEBIAN/control
	echo "Description: Subida de archivos a Azure Blob Storage desde un archivo de configuración" >> $(DEB_DIR)/DEBIAN/control
	@echo "=== Generando el paquete .deb ==="
	dpkg-deb --build $(DEB_DIR)
	@echo "=== Paquete Debian generado: $(DEB_PACKAGE) ==="

# Limpiar archivos de compilación
clean:
	@echo "=== Limpiando archivos anteriores ==="
	rm -rf dist build *.deb $(PACKAGE_NAME).spec

# Instalar el paquete Debian en el sistema local
install: deb
	@echo "=== Instalando el paquete ==="
	sudo dpkg -i $(DEB_PACKAGE)

