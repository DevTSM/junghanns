import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:junghanns/pages/chat/whatsApp_full_screen_video.dart';
import 'package:http/http.dart' as http;

class WhatsAppVideoPreview extends StatefulWidget {
  final String videoUrl;

  const WhatsAppVideoPreview({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<WhatsAppVideoPreview> createState() => _WhatsAppVideoPreviewState();
}

class _WhatsAppVideoPreviewState extends State<WhatsAppVideoPreview> {
  String? _thumbnailPath;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isVideoDownloaded = false;
  String? _localVideoPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
    _checkVideoDownloaded();
  }

  // Verifica si el video ya está descargado localmente
  Future<void> _checkVideoDownloaded() async {
    final tempDir = await getTemporaryDirectory();
    final fileName = widget.videoUrl.split('/').last.split('?').first; // Elimina parámetros
    final localPath = '${tempDir.path}/$fileName';

    print("Verificando si el video ya está descargado en: $localPath");

    if (await File(localPath).exists()) {
      setState(() {
        _isVideoDownloaded = true;
        _localVideoPath = localPath;
      });
      print("El video ya está descargado en: $_localVideoPath");
    } else {
      print("El video no está descargado. Iniciando descarga...");
      _downloadVideo(localPath);
    }
  }


// Descarga el video y guarda el archivo localmente
  Future<void> _downloadVideo(String localPath) async {
    final response = await http.get(Uri.parse(widget.videoUrl));

    if (response.statusCode == 200) {
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        _isVideoDownloaded = true;
        _localVideoPath = localPath;
      });
      print("El video se descargó y se guardó en: $_localVideoPath");
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print("Error al descargar el video");
    }
  }

// Abre el video en pantalla completa
  void _openFullScreenVideo() {
    String videoPath = _isVideoDownloaded ? _localVideoPath! : widget.videoUrl;
    print("Abriendo video desde: $videoPath");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppFullScreenVideo(videoUrl: videoPath),
      ),
    );
  }

  // Genera la miniatura del video
  Future<void> _generateThumbnail() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200, // Ajusta la altura de la miniatura
        quality: 75, // Ajusta la calidad de la miniatura
      );

      if (thumbnailPath != null) {
        setState(() {
          _thumbnailPath = thumbnailPath;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error generando miniatura: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullScreenVideo,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isLoading
                ? Container(
              width: 250,
              height: 250,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            )
                : _hasError
                ? Container(
              width: 250,
              height: 250,
              color: Colors.grey[300],
              child: const Center(child: Text('Error al cargar el video')),
            )
                : _thumbnailPath != null
                ? Image.file(
              File(_thumbnailPath!),
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            )
                : Container(
              width: 250,
              height: 250,
              color: Colors.black12,
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
