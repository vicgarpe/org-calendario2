import json
import os
import argparse
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from azure.core.exceptions import AzureError

# Ruta por defecto al archivo de configuración
DEFAULT_CONFIG_DIR = os.path.join(os.path.expanduser("~"), ".vgp", "bullettoical")
DEFAULT_CONFIG_FILE = os.path.join(DEFAULT_CONFIG_DIR, "config.json")


def crear_configuracion_plantilla(config_file):
    """Crea una plantilla de archivo de configuración si no existe."""
    plantilla = {
        "connection_string": "DefaultEndpointsProtocol=https;AccountName=tu_cuenta;AccountKey=tu_clave;EndpointSuffix=core.windows.net",
        "container_name": "nombre_del_contenedor",
        "files": [
            {
                "file_path": "ruta/al/archivo1.txt",
                "blob_name": "blob1.txt"
            },
            {
                "file_path": "ruta/al/archivo2.txt",
                "blob_name": "blob2.txt"
            }
        ]
    }

    # Crear directorio si no existe
    os.makedirs(os.path.dirname(config_file), exist_ok=True)

    # Crear el archivo de configuración
    with open(config_file, 'w') as f:
        json.dump(plantilla, f, indent=4)
    print(f"Archivo de configuración de plantilla creado en: {config_file}")


def cargar_configuracion(config_file):
    """Lee el archivo de configuración JSON."""
    if not os.path.exists(config_file):
        print(f"Archivo de configuración no encontrado en {config_file}. Creando archivo de plantilla...")
        crear_configuracion_plantilla(config_file)
        raise FileNotFoundError(f"Por favor rellena la plantilla en {config_file} antes de ejecutar el script nuevamente.")
    
    with open(config_file, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError as e:
            raise ValueError(f"Error en el formato del archivo JSON: {e}")


def subir_archivo_a_blob(blob_service_client, container_name, file_path, blob_name):
    """Sube un archivo al Azure Blob Storage."""
    try:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"El archivo {file_path} no existe.")
        
        # Obtener el cliente de blob
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        
        # Subir el archivo
        with open(file_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)
        print(f"Archivo {file_path} subido correctamente como {blob_name}.")
    
    except AzureError as e:
        print(f"Error al intentar conectarse a Azure Blob Storage: {e}")
    except Exception as e:
        print(f"Error al subir {file_path} a {blob_name}: {e}")


def main():
    # Argumentos del script
    parser = argparse.ArgumentParser(description="Subir archivos a Azure Blob Storage desde un archivo de configuración.")
    parser.add_argument(
        '-c', '--config', 
        help='Ruta alternativa al archivo de configuración.', 
        default=None
    )
    args = parser.parse_args()

    # Definir ruta del archivo de configuración
    if args.config:
        config_file = args.config
    else:
        config_file = DEFAULT_CONFIG_FILE

    # Si no se proporciona un archivo alternativo, crear las carpetas por defecto si no existen
    if not args.config and not os.path.exists(DEFAULT_CONFIG_DIR):
        print(f"Creando carpetas de configuración en {DEFAULT_CONFIG_DIR}...")
        os.makedirs(DEFAULT_CONFIG_DIR, exist_ok=True)

    # Cargar configuración desde el archivo JSON
    try:
        config_data = cargar_configuracion(config_file)
    except Exception as e:
        print(f"Error al cargar el archivo de configuración: {e}")
        return

    # Extraer la cadena de conexión y el nombre del contenedor del archivo de configuración
    connection_string = config_data.get("connection_string")
    container_name = config_data.get("container_name")

    if not connection_string or not container_name:
        print("Error: La cadena de conexión o el nombre del contenedor no están definidos en el archivo de configuración.")
        return

    # Crear el cliente de BlobService
    try:
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    except AzureError as e:
        print(f"Error al conectar a Azure Blob Storage con la cadena de conexión: {e}")
        return

    # Iterar sobre los archivos y blobs en la configuración
    for item in config_data.get('files', []):
        file_path = item.get('file_path')
        blob_name = item.get('blob_name')
        
        if file_path and blob_name:
            subir_archivo_a_blob(blob_service_client, container_name, file_path, blob_name)
        else:
            print(f"Configuración inválida para el archivo: {item}")


if __name__ == "__main__":
    main()
