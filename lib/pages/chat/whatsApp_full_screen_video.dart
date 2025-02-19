/*
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WhatsAppFullScreenVideo extends StatefulWidget {
  final String videoUrl;

  const WhatsAppFullScreenVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<WhatsAppFullScreenVideo> createState() => _WhatsAppFullScreenVideoState();
}

class _WhatsAppFullScreenVideoState extends State<WhatsAppFullScreenVideo> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);
    await _videoController.initialize();
    _videoController.play();
    setState(() {
      _isPlaying = true;
    });

    _videoController.addListener(() {
      if (_videoController.value.position == _videoController.value.duration) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      _isPlaying = _videoController.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Video en pantalla completa
          _videoController.value.isInitialized
              ? Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),
          )
              : const Center(child: CircularProgressIndicator()),

          // Botón de Play/Pause
          AnimatedOpacity(
            opacity: _isPlaying ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

          // Botón de cerrar
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Barra de progreso
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: VideoProgressIndicator(
              _videoController,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.greenAccent,
                backgroundColor: Colors.white30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WhatsAppFullScreenVideo extends StatefulWidget {
  final String videoUrl;

  const WhatsAppFullScreenVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<WhatsAppFullScreenVideo> createState() => _WhatsAppFullScreenVideoState();
}

class _WhatsAppFullScreenVideoState extends State<WhatsAppFullScreenVideo> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);
    await _videoController.initialize();
    _videoController.play();
    setState(() {
      _isPlaying = true;
    });

    _videoController.addListener(() {
      setState(() {
        _sliderValue = _videoController.value.position.inMilliseconds.toDouble();
        if (_videoController.value.position >= _videoController.value.duration) {
          _isPlaying = false;
        }
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      _isPlaying = _videoController.value.isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Video en pantalla completa
          _videoController.value.isInitialized
              ? Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),
          )
              : const Center(child: CircularProgressIndicator()),

          // Botón de Play/Pause
          AnimatedOpacity(
            opacity: _isPlaying ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

          // Botón de cerrar
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Barra de progreso con tiempos
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _videoController.value.isInitialized
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_videoController.value.position),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      _formatDuration(_videoController.value.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3, // Grosor de la barra
                    activeTrackColor: Colors.greenAccent, // Color de progreso
                    inactiveTrackColor: Colors.white30, // Color de fondo
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), // Tamaño de la bolita
                    thumbColor: Colors.greenAccent, // Color de la bolita
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 0.0,
                    max: _videoController.value.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                      _videoController.seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
