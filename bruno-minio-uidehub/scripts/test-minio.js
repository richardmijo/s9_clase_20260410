const Minio = require('minio');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const endPoint = process.env.MINIO_ENDPOINT || 's3.uidehub.tech';
const port = parseInt(process.env.MINIO_PORT || '443');
const useSSL = process.env.MINIO_USE_SSL === 'true';
const accessKey = process.env.MINIO_ACCESS_KEY || 'admin_uidehub';
const secretKey = process.env.MINIO_SECRET_KEY;
const bucketName = process.env.MINIO_BUCKET || 'pruebas';
const objectName = 'prueba.txt';

if (!secretKey || secretKey === 'tu_secret_key_aqui') {
  console.error('Error: Debes configurar MINIO_SECRET_KEY en tu archivo .env');
  process.exit(1);
}

// Inicializar cliente MinIO
const minioClient = new Minio.Client({
  endPoint: endPoint,
  port: port,
  useSSL: useSSL,
  accessKey: accessKey,
  secretKey: secretKey
});

async function run() {
  try {
    console.log(`Conectando a MinIO en: ${useSSL ? 'https://' : 'http://'}${endPoint}:${port}`);

    // 1. Crear bucket si no existe
    const bucketExists = await minioClient.bucketExists(bucketName);
    if (!bucketExists) {
      console.log(`Creando el bucket "${bucketName}"...`);
      await minioClient.makeBucket(bucketName, 'us-east-1');
      console.log(`Bucket "${bucketName}" creado con éxito.`);
    } else {
      console.log(`El bucket "${bucketName}" ya existe.`);
    }

    // 2. Crear un archivo local de prueba para subir
    const localFilePath = path.join(__dirname, 'prueba.txt');
    fs.writeFileSync(localFilePath, 'Hola Mundo desde el Script de Validación de MinIO Node.js!\nFecha: ' + new Date().toISOString());
    console.log(`Archivo de prueba local creado en: ${localFilePath}`);

    // 3. Subir archivo a MinIO
    console.log(`Subiendo "${objectName}" al bucket "${bucketName}"...`);
    await minioClient.fPutObject(bucketName, objectName, localFilePath);
    console.log('Archivo subido con éxito.');

    // 4. Listar objetos en el bucket
    console.log(`Listando objetos en el bucket "${bucketName}":`);
    const objectsList = [];
    const stream = minioClient.listObjects(bucketName, '', true);
    for await (const obj of stream) {
      console.log(` - ${obj.name} (${obj.size} bytes)`);
      objectsList.push(obj);
    }

    // 5. Descargar el archivo
    const downloadFilePath = path.join(__dirname, 'descargado_prueba.txt');
    console.log(`Descargando "${objectName}" a: ${downloadFilePath}`);
    await minioClient.fGetObject(bucketName, objectName, downloadFilePath);
    const content = fs.readFileSync(downloadFilePath, 'utf8');
    console.log('Archivo descargado con éxito. Contenido:');
    console.log('--------------------------------------------------');
    console.log(content);
    console.log('--------------------------------------------------');

    // 6. Eliminar archivo de MinIO
    console.log(`Eliminando objeto "${objectName}" del bucket "${bucketName}"...`);
    await minioClient.removeObject(bucketName, objectName);
    console.log('Objeto eliminado con éxito de MinIO.');

    // Limpiar archivos locales temporales
    if (fs.existsSync(localFilePath)) fs.unlinkSync(localFilePath);
    if (fs.existsSync(downloadFilePath)) fs.unlinkSync(downloadFilePath);

    // 7. Dejar comentada la eliminación del bucket
    // console.log(`Eliminando el bucket "${bucketName}"...`);
    // await minioClient.removeBucket(bucketName);
    // console.log(`Bucket "${bucketName}" eliminado.`);
    console.log('\nPrueba completada con éxito.');

  } catch (error) {
    console.error('Ocurrió un error en la prueba:', error);
  }
}

run();
