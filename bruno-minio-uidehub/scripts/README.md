# Validación de MinIO UIDE Hub

Este directorio contiene herramientas para probar y validar la conexión a tu servidor VPS de MinIO.

## Estructura
- **Colección Bruno**: Ubicada en la raíz del directorio `bruno-minio-uidehub/`. Contiene requests HTTP preconfigurados con firma AWS Signature V4.
- **Script de Pruebas en Node.js**: Ubicado en este directorio `scripts/`, para probar de forma automatizada las operaciones de S3 utilizando el cliente oficial de MinIO para Node.js.

---

## 1. Validación con el Script de Node.js

Sigue estos pasos para ejecutar el script de validación:

### Requisitos Previos
- Tener instalado [Node.js](https://nodejs.org/) (versión 16 o superior).

### Paso 1: Instalar las dependencias
Abre tu terminal en esta carpeta (`bruno-minio-uidehub/scripts/`) y ejecuta:
```bash
npm install
```

### Paso 2: Configurar las Variables de Entorno
Copia el archivo de ejemplo `.env.example` y nómbralo `.env`:
```bash
cp .env.example .env
```
Abre el archivo `.env` recién creado y define tu clave secreta:
```env
MINIO_SECRET_KEY=tu_secret_key_aqui
```

### Paso 3: Ejecutar la prueba
Ejecuta el siguiente comando para correr el script:
```bash
npm start
```

El script realizará el siguiente flujo:
1. Conectarse a `https://s3.uidehub.tech` con SSL en el puerto `443`.
2. Verificar si el bucket `pruebas` existe (si no, lo crea).
3. Generar y subir un archivo temporal `prueba.txt`.
4. Listar todos los objetos en el bucket.
5. Descargar el archivo `prueba.txt` y mostrar su contenido por consola.
6. Eliminar el archivo de MinIO.
7. Dejar limpia la zona de trabajo.

---

## 2. Validación con la Colección Bruno

Si prefieres usar la herramienta de interfaz visual **Bruno**:

1. Abre la aplicación **Bruno**.
2. Selecciona **Open Collection** en el menú de inicio.
3. Elige la carpeta raíz `bruno-minio-uidehub` de este proyecto.
4. Una vez abierta la colección, selecciona el entorno `uidehub` (disponible en la esquina superior derecha).
5. Configura tu clave secreta en las variables del entorno haciendo clic en **Configure** -> **Secret Key** y cambiando `CAMBIAR` por tu secreto.
6. Ejecuta los requests secuencialmente:
   - **Health Check**: Endpoint público de salud (`/minio/health/live`).
   - **List Buckets**: Obtiene el catálogo de buckets.
   - **Create Bucket**: Crea el bucket parametrizado (`pruebas`).
   - **Upload File**: Sube un texto de prueba.
   - **Download File**: Descarga y visualiza el texto.
   - **Delete File**: Borra el archivo de pruebas de la VPS.
