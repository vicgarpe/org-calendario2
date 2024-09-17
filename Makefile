# Nombre del paquete y la versión
PACKAGE_NAME = bullettoical
VERSION = 1.0.1
ARCH = all

# Nombre del script de Python
PYTHON_SCRIPT = publica-azure.py
# Nombre del ejecutable será el mismo que el script de Python pero sin la extensión .py
EXECUTABLE_NAME = $(basename $(PYTHON_SCRIPT))

# Directorios para la estructura de paquetes Debian
BUILD_DIR = build
DEB_DIR = $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)
DEB_BIN_DIR = $(DEB_DIR)/usr/local/bin
DEB_DOC_DIR = $(DEB_DIR)/usr/share/doc/$(PACKAGE_NAME)
DEB_INFO_DIR = $(DEB_DIR)/usr/share/info
DEB_MAN_DIR = $(DEB_DIR)/usr/share/man/man1

# Nombre del archivo .deb final
DEB_PACKAGE = $(PACKAGE_NAME)_$(VERSION)_$(ARCH).deb

# Rutas a los archivos fuente de info y man
INFO_TEXI_FILE = info/$(PACKAGE_NAME).texi
INFO_FILE = $(PACKAGE_NAME).info
MAN_FILE = man/$(EXECUTABLE_NAME).1

.PHONY: all clean build deb install

# Regla principal
all: clean build deb

# Crear el binario de Python con PyInstaller
build: $(EXECUTABLE_NAME) $(INFO_FILE) $(MAN_FILE)
	@echo "=== Preparando la estructura de carpetas del paquete Debian ==="
	mkdir -p $(DEB_BIN_DIR)
	mkdir -p $(DEB_DOC_DIR)
	mkdir -p $(DEB_INFO_DIR)
	mkdir -p $(DEB_MAN_DIR)
	@echo "=== Copiando binario al directorio de destino ==="
	cp dist/$(EXECUTABLE_NAME) $(DEB_BIN_DIR)/$(EXECUTABLE_NAME)
	@echo "=== Copiando documentación (si existe) ==="
	if [ -d "doc" ]; then cp -r doc/* $(DEB_DOC_DIR)/; else echo "No se encontró la carpeta 'doc', omitiendo."; fi
	@echo "=== Copiando archivo info ==="
	cp $(INFO_FILE) $(DEB_INFO_DIR)
	@echo "=== Copiando archivo man ==="
	cp $(MAN_FILE) $(DEB_MAN_DIR)/$(EXECUTABLE_NAME).1

# Crear el ejecutable a partir del script de Python usando PyInstaller
$(EXECUTABLE_NAME): $(PYTHON_SCRIPT)
	@echo "=== Creando el binario de Python ==="
	pyinstaller --onefile $(PYTHON_SCRIPT)
	@echo "=== Ejecutable generado con nombre: $(EXECUTABLE_NAME) ==="

# Crear el archivo .info a partir del .texi
$(INFO_FILE): $(INFO_TEXI_FILE)
	@echo "=== Generando archivo .info a partir de .texi ==="
	makeinfo --output=$(INFO_FILE) $(INFO_TEXI_FILE)

# Usar el archivo man desde la carpeta man/
$(MAN_FILE):
	@echo "=== Archivo man encontrado en la carpeta man/ ==="
	if [ ! -f $(MAN_FILE) ]; then echo "Archivo man no encontrado"; exit 1; fi

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
	@echo "=== Copiando archivos postinst y prerm ==="
	cp DEBIAN/* $(DEB_DIR)/DEBIAN
	chmod 0775 $(DEB_DIR)/DEBIAN/p*
	@echo "=== Generando el paquete .deb ==="
	dpkg-deb --build $(DEB_DIR)
	@echo "=== Paquete Debian generado: $(DEB_PACKAGE) ==="

# Limpiar archivos de compilación
clean:
	@echo "=== Limpiando archivos anteriores ==="
	rm -rf dist build *.deb $(EXECUTABLE_NAME).spec $(INFO_FILE)

# Instalar el paquete Debian en el sistema local
install:
	@echo "=== Instalando el paquete ==="
	@echo "Instala de forma manual"
