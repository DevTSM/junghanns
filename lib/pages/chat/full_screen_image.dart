/*
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  String? _localFilePath;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  // Verifica si la imagen ya está descargada
  Future<bool> _isFileExists(String path) async {
    return File(path).exists();
  }

  // Prepara la imagen, descargándola si es necesario
  Future<void> _prepareImage() async {
    final directory = await getExternalStorageDirectory();
    final fileName = widget.imageUrl.split('/').last.split('?').first; // ✅ Elimina parámetros
    _localFilePath = '${directory!.path}/$fileName';

    if (await _isFileExists(_localFilePath!)) {
      // La imagen ya está guardada localmente
      setState(() {});
    } else {
      // Si no está, la descargamos en segundo plano
      _downloadImage();
    }
  }

  // Descarga la imagen en segundo plano
  Future<void> _downloadImage() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      Dio dio = Dio();
      Response response = await dio.download(widget.imageUrl, _localFilePath!);

      if (response.statusCode == 200) {
        print('Imagen descargada correctamente: $_localFilePath');
      } else {
        print('Error al descargar la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al descargar la imagen: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: widget.imageUrl,
          child: _isDownloading
              ? const CircularProgressIndicator(color: Colors.white)
              : InteractiveViewer(
            child: _localFilePath != null && File(_localFilePath!).existsSync()
                ? Image.file(File(_localFilePath!), fit: BoxFit.contain)
                : Image.network(widget.imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
