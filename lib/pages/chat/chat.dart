import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junghanns/pages/chat/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:junghanns/provider/chat_provider.dart';
import '../../styles/color.dart';
import 'audio_player_widget.dart';
import 'file_download_and_open.dart';
import 'full_screen_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: ColorsJunghanns.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                bool isMe = msg["userId"] == chatProvider.myUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.lightBlue[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar nombre solo si el userId es diferente de tu prefs.nameUserD
                        if (msg["userId"] != chatProvider.myUserId) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              msg["userId"] ?? "Usuario",  // Muestra el nombre del usuario
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                        // Mensaje
                        _buildMessageContent(msg),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      filled: true,
                      fillColor: Colors.blue[50],
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _pickAndSendFile(context),
                              child: const Icon(Icons.attach_file, color: Colors.blue, size: 22),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _takeAndSendPhoto(context),
                              child: const Icon(Icons.camera_alt, color: Colors.blue, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: ColorsJunghanns.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        chatProvider.sendMessage(controller.text);
                        controller.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMessageContent(Map<String, dynamic> msg) {
    if (msg["type"] == "text") {
      return Text(
        msg["message"] ?? "",
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.left,
      );
    } else if (msg["type"] == "file") {
      String fileType = msg["fileType"] ?? "";
      String fileUrl = "http://192.168.0.15:3000" + (msg["fileUrl"] ?? "");

      // Extraemos el nombre del archivo de la URL
      String fileName = Uri.parse(fileUrl).pathSegments.last;

      if (fileType.startsWith("image/")) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(imageUrl: fileUrl),
              ),
            );
          },
          child: Hero(
            tag: fileUrl,
            child: Image.network(
              fileUrl,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (fileType.startsWith("video/")) {
        return _buildVideoPlayer(fileUrl);
      } else if (fileType.startsWith("audio/")) {
        return _buildAudioPlayer(fileUrl);
      } else {
        return _buildFileMessage(fileUrl, fileName);
      }
    }
    return Container();
  }

  // 📸 **Instancia para tomar fotos**
  final ImagePicker _picker = ImagePicker();

  /// 📸 **Tomar foto y enviarla**
  Future<void> _takeAndSendPhoto(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File file = File(image.path);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.sendFile(file.path);
      _scrollToBottom();
    }
  }

  /// 🔹 **Construye el contenido del mensaje**
  Widget _buildFileMessage(String fileUrl, String fileName) {
    String fileExtension = fileName.split('.').last.toUpperCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.insert_drive_file,
          color: Colors.grey, // Color gris
          size: 30, // Tamaño del ícono
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Crear una instancia de FileDownloadAndOpen y descargar o abrir el archivo
              final fileDownloadAndOpen = FileDownloadAndOpen();
              fileDownloadAndOpen.downloadAndOpenFile(fileUrl, fileName); // Llamar al método
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Fondo suave
                borderRadius: BorderRadius.circular(12), // Bordes redondeados
                border: Border.all(color: Colors.blue[300]!, width: 1), // Borde suave
              ),
              child: Text(
                fileName,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📂 **Seleccionar y enviar un archivo**
  void _pickAndSendFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.sendFile(file.path);
      _scrollToBottom();
    }
  }

  /// 🎥 **Reproductor de video**
  Widget _buildVideoPlayer(String fileUrl) {
    return WhatsAppVideoPreview(videoUrl: fileUrl);
  }

  /// 🎵 **Reproductor de audio**
  Widget _buildAudioPlayer(String fileUrl) {
    return AudioPlayerWidget(audioUrl: fileUrl);
  }

}

