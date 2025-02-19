/*
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.blue),
            onPressed: () {
              _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
            },
          ),
          Expanded(
            child: Slider(
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[400],
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Text(
            _formatDuration(_position),
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
*//*

*/
/*import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de Play/Pausa con animación
          GestureDetector(
            onTap: () {
              _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: _isPlaying ? 10 : 0,
                    spreadRadius: _isPlaying ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Barra de progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[300],
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                // Tiempo transcurrido y duración total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}*//*

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de Play/Pausa
          GestureDetector(
            onTap: () {
              _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isPlaying ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Barra de progreso con gradiente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // Tiempo transcurrido y total con alineación mejorada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
*/
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _prepareAudio();
  }

  Future<void> _prepareAudio() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = widget.audioUrl.split('/').last;
    _localFilePath = '${directory.path}/$fileName';

    print('Verificando si el archivo ya existe en: $_localFilePath');

    if (await _isFileExists(_localFilePath!)) {
      // Si el archivo ya está descargado, lo reproduce desde el dispositivo.
      print('El archivo ya está descargado, preparando para reproducir...');
      _audioPlayer.setFilePath(_localFilePath!);
    } else {
      // Si el archivo no está descargado, se reproduce directamente desde la URL mientras se descarga.
      print('El archivo no está descargado, reproduciendo desde la URL y descargando en segundo plano...');
      _audioPlayer.setUrl(widget.audioUrl);
      _downloadAndPlayAudio();  // Inicia la descarga en segundo plano.
    }

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  Future<bool> _isFileExists(String path) async {
    final file = File(path);
    return file.exists();
  }

  Future<void> _downloadAndPlayAudio() async {
    setState(() {
      _isDownloading = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final fileName = widget.audioUrl.split('/').last;
    final filePath = '${directory.path}/$fileName';

    // Verifica permisos para almacenamiento
    if (await Permission.storage.request().isGranted) {
      try {
        print('Iniciando descarga del archivo desde: ${widget.audioUrl}');
        final dio = Dio();
        await dio.download(widget.audioUrl, filePath);
        setState(() {
          _isDownloading = false;
        });
        print('Descarga completada, preparando archivo para reproducción...');

        // Reproduce el archivo descargado localmente.
        _audioPlayer.setFilePath(filePath);
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });
        print('Error durante la descarga: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al descargar el audio')));
      }
    } else {
      setState(() {
        _isDownloading = false;
      });
      print('Permisos de almacenamiento denegados.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permisos de almacenamiento denegados')));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de Play/Pausa
          GestureDetector(
            onTap: () {
              if (!_isDownloading) {
                _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isPlaying ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Barra de progreso con gradiente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // Tiempo transcurrido y total con alineación mejorada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isDownloading)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
*/
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _prepareAudio();
  }

  Future<void> _prepareAudio() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = widget.audioUrl.split('/').last;
    _localFilePath = '${directory.path}/$fileName';

    print('Verificando si el archivo ya existe en: $_localFilePath');

    if (await _isFileExists(_localFilePath!)) {
      // Si el archivo ya está descargado, lo reproduce desde el dispositivo.
      print('El archivo ya está descargado, preparando para reproducir...');
      _audioPlayer.setFilePath(_localFilePath!);
    } else {
      // Si el archivo no está descargado, se reproduce directamente desde la URL mientras se descarga.
      print('El archivo no está descargado, reproduciendo desde la URL y descargando en segundo plano...');
      _audioPlayer.setUrl(widget.audioUrl);
      _downloadAndPlayAudio();  // Inicia la descarga en segundo plano.
    }

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  Future<bool> _isFileExists(String path) async {
    final file = File(path);  // Asegúrate de usar File de dart:io
    return file.exists();
  }

  Future<void> _downloadAndPlayAudio() async {
    setState(() {
      _isDownloading = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final fileName = widget.audioUrl.split('/').last;
    final filePath = '${directory.path}/$fileName';

    // Verifica el permiso para el almacenamiento
    PermissionStatus status = await Permission.storage.request();

    if (Platform.isAndroid && await Permission.storage.isDenied) {
      if (await Permission.manageExternalStorage.isGranted) {
        // Si el permiso MANAGE_EXTERNAL_STORAGE está concedido, lo pedimos
        status = await Permission.manageExternalStorage.request();
      }
    }

    if (status.isGranted) {
      try {
        print('Iniciando descarga del archivo desde: ${widget.audioUrl}');
        final dio = Dio();
        await dio.download(widget.audioUrl, filePath);
        setState(() {
          _isDownloading = false;
        });
        print('Descarga completada, preparando archivo para reproducción...');
        _audioPlayer.setFilePath(filePath);
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });
        print('Error durante la descarga: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al descargar el audio')));
      }
    } else {
      setState(() {
        _isDownloading = false;
      });
      */
/*print('Permisos de almacenamiento denegados.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permisos de almacenamiento denegados')));
*//*

      // Verificar si el permiso ha sido denegado permanentemente
      if (await Permission.storage.isPermanentlyDenied) {

        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El permiso de almacenamiento ha sido denegado permanentemente.')));
        openAppSettings(); // Redirige al usuario a la configuración
      }
    }
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de Play/Pausa
          GestureDetector(
            onTap: () {
              if (!_isDownloading) {
                _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isPlaying ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Barra de progreso con gradiente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // Tiempo transcurrido y total con alineación mejorada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isDownloading)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _prepareAudio();
  }

  // Verificar si el archivo ya existe en la ubicación dada
  Future<bool> _isFileExists(String path) async {
    final file = File(path);
    return file.exists();
  }

  // Preparar el audio, comprobando si ya está descargado o si es necesario descargarlo
  Future<void> _prepareAudio() async {
    final directory = await getExternalStorageDirectory();
    final fileName = widget.audioUrl.split('/').last;
    _localFilePath = '${directory!.path}/$fileName'; // Usamos el almacenamiento externo

    print('Verificando si el archivo ya existe en: $_localFilePath');

    if (await _isFileExists(_localFilePath!)) {
      // Si el archivo ya está descargado, lo reproduce desde el dispositivo.
      print('El archivo ya está descargado, preparando para reproducir...');
      _audioPlayer.setFilePath(_localFilePath!);
    } else {
      // Si el archivo no está descargado, se reproduce directamente desde la URL mientras se descarga.
      print('El archivo no está descargado, reproduciendo desde la URL y descargando en segundo plano...');
      _audioPlayer.setUrl(widget.audioUrl);
      _downloadAndPlayAudio();  // Inicia la descarga en segundo plano.
    }

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  // Descargar el archivo de audio
  Future<void> _downloadAndPlayAudio() async {
    setState(() {
      _isDownloading = true;
    });

    final directory = await getExternalStorageDirectory();
    final fileName = widget.audioUrl.split('/').last;
    final filePath = '${directory!.path}/$fileName';

    try {
      Dio dio = Dio();
      Response response = await dio.download(widget.audioUrl, filePath);

      if (response.statusCode == 200) {
        print('Archivo descargado correctamente: $filePath');
        // Establecemos la ruta del archivo descargado para reproducirlo
        await _audioPlayer.setFilePath(filePath);
        setState(() {
          _isDownloading = false;
        });
        //_audioPlayer.play();  // Iniciamos la reproducción
      } else {
        print('Error al descargar el archivo: ${response.statusCode}');
        setState(() {
          _isDownloading = false;
        });
      }
    } catch (e) {
      print('Error al descargar el archivo: $e');
      setState(() {
        _isDownloading = false;
      });
    }
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de Play/Pausa
          GestureDetector(
            onTap: () {
              if (!_isDownloading) {
                _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isPlaying ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Barra de progreso con gradiente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // Tiempo transcurrido y total con alineación mejorada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isDownloading)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
