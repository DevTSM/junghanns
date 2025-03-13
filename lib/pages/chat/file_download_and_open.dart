import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart'; // Para obtener rutas de almacenamiento
import 'package:permission_handler/permission_handler.dart';

class FileDownloadAndOpen {
  // Función para pedir permisos de almacenamiento
  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permiso de almacenamiento denegado');
    }
  }

  // Función para descargar el archivo si no existe, y abrirlo
  Future<void> downloadAndOpenFile(String fileUrl, String fileName) async {
    await _requestStoragePermission(); // Solicitar permisos

    try {
      // Obtener el directorio de descarga en el dispositivo
      Directory appDocDir = await getExternalStorageDirectory() ?? Directory('');
      String filePath = '${appDocDir.path}/$fileName'; // Ruta donde se guardará el archivo

      // Verificar si el archivo ya existe
      bool fileExists = await File(filePath).exists();

      if (fileExists) {
        // Si el archivo ya existe, solo lo abrimos
        print('El archivo ya existe, abriéndolo: $filePath');
        await _openDownloadedFile(filePath);
      } else {
        // Si el archivo no existe, lo descargamos
        print('Descargando el archivo: $filePath');
        await _downloadFile(fileUrl, filePath); // Llamamos al método de descarga
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para descargar el archivo
  Future<void> _downloadFile(String fileUrl, String filePath) async {
    try {
      Dio dio = Dio();
      Response response = await dio.download(fileUrl, filePath);

      if (response.statusCode == 200) {
        print('Archivo descargado correctamente: $filePath');
        await _openDownloadedFile(filePath); // Abre el archivo después de descargarlo
      } else {
        print('Error al descargar el archivo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al descargar el archivo: $e');
    }
  }

  // Función para abrir el archivo descargado
  Future<void> _openDownloadedFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print('No se pudo abrir el archivo: $filePath');
    }
  }
}
