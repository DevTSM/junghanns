import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/pages/chat/video_player_widget.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:junghanns/provider/chat_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chat/message_model.dart';
import '../../styles/color.dart';
import 'ChatBubbleClipper.dart';
import 'audio_player_widget.dart';
import 'file_download_and_open.dart';
import 'full_screen_image.dart';
import 'full_screen_map.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime _currentDate = DateTime.now(); // Fecha actual, se actualizará con cada scroll
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMessages(_currentDate);  // Cargar mensajes iniciales
    _scrollController.addListener(_scrollListener);
  }

  // Método para cargar los mensajes
  void _loadMessages(DateTime date) async {
    // Convierte la fecha a un formato que tu backend pueda manejar, por ejemplo en Unix Timestamp
    int unixTimestamp = date.millisecondsSinceEpoch ~/ 1000;

    print("Cargando mensajes desde: $unixTimestamp");
    await Provider.of<ChatProvider>(context, listen: false).getMessages(date: _currentDate); // Cargar mensajes del día anterior

    _scrollListener();
  }

  Future<void> _scrollListener() async {
    if (_scrollController.hasClients && _scrollController.position.pixels <= 50 && !isLoading) {
      setState(() => isLoading = true);

      bool messagesLoaded = false;
      int attempts = 0; // Contador de intentos para evitar un bucle infinito

      // Continuar retrocediendo mientras no haya mensajes o se esté buscando
      while (!messagesLoaded && attempts < 7) { // Se limita a un número máximo de intentos por seguridad
        // Cargar mensajes del día anterior
        _currentDate = _currentDate.subtract(const Duration(days: 1));
        print("Cargando mensajes del día: $_currentDate");

        var newMessages = await Provider.of<ChatProvider>(context, listen: false).getMessages(date: _currentDate);

        // Si se encontraron mensajes, actualizar la variable `messagesLoaded`
        if (newMessages != null && newMessages.isNotEmpty) {
          print("Mensajes obtenidos: ${newMessages.length}");
          setState(() {
            // Agregar los nuevos mensajes al principio de la lista
            Provider.of<ChatProvider>(context, listen: false).chatMessages.insertAll(0, newMessages);
          });
          messagesLoaded = true;
        } else {
          print("No se encontraron mensajes para el día $_currentDate, buscando más atrás.");

          // Si no se encontraron mensajes, seguir buscando más atrás
          attempts++; // Incrementar el contador de intentos
          if (attempts >= 7) {
            print("No hay más mensajes anteriores.");
            setState(() {
              isLoading = false; // Detener el indicador de carga cuando ya no hay más mensajes
            });
            break;
          }
          // Si no hay mensajes, seguir retrocediendo
          await Future.delayed(const Duration(milliseconds: 500)); // Esperar un pequeño delay antes de seguir cargando
        }
      }
    }
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
      backgroundColor: ColorsJunghanns.lightBlue,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,  // Los mensajes más recientes aparecen al final
              /*itemCount: chatProvider.chatMessages.length,
              itemBuilder: (context, index) {*/
              itemCount: chatProvider.chatMessages.length + 1,   // +1 para el indicador de carga
              itemBuilder: (context, index) {
                if (index == chatProvider.chatMessages.length) {
                  return isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : const SizedBox.shrink();
                }
                final msg = chatProvider.chatMessages[index];
                bool isMe = msg.user == 'Tú';  // Comparar con tu usuario

                // Convertir el timestamp a DateTime
                DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(msg.registeredAt * 1000);

                // Formatear la fecha
                String formattedDate = DateFormat('dd MMM yyyy').format(messageDate);

                // Verificar si se debe mostrar la fecha
                bool showDate = _shouldDisplayDate(index, messageDate);

                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (showDate) ...[
                      // Mostrar la fecha solo si es necesario
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],  // Fondo crema
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Mensaje con colita pegada
                    Stack(
                      clipBehavior: Clip.none, // Permite que la colita sobresalga
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.lightBlue : ColorsJunghanns.blueT,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.user != 'Tú') ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    msg.user,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              _buildMessageContent(msg),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a').format(messageDate), // Formato de 12 horas (ej: 10:30 PM)
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                   /* if (isMe) ...[  // Solo muestra las palomitas si el mensaje es mío
                                      const SizedBox(width: 5), // Espaciado entre la hora y las palomitas
                                      Icon(
                                        msg.isCheck == true
                                            ? Icons.check
                                            : Icons.access_time, // Primera palomita o reloj
                                        size: 15,
                                        color: Colors.white70,
                                      ),
                                      if (msg.info.read == false) ...[
                                       // const SizedBox(width: 3), // Espaciado mínimo entre los checks
                                        const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Colors.white70, // Palomita azul (leído)
                                        ),
                                      ],
                                    ],*/
                                    /*if (isMe) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Primera palomita o reloj
                                          Transform.translate(
                                            offset: Offset(8, 0),
                                            child: Icon(
                                              msg.isCheck == true ? Icons.check : Icons.access_time,
                                              size: 15,
                                              color: Colors.white70,
                                            ),
                                          ),

                                          // Segunda palomita si no está leída
                                          if (msg.info.read == false) ...[
                                            Transform.translate(
                                              offset: Offset(0, 0), // Ajusta la posición hacia la izquierda
                                              child: const Icon(
                                                Icons.check,
                                                size: 15,
                                                color: Colors.white70, // Palomita azul (leído)
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ]*/
                                    if (isMe) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 3), // Espaciado entre la hora y las palomitas
                                          // Primera palomita o reloj
                                          Transform.translate(
                                            offset: Offset(8, 0),
                                            child: Icon(
                                              msg.isCheck == true ? Icons.check : Icons.access_time,
                                              size: 15,
                                              color: msg.info.received == false ? Colors.white : Colors.white70, // Cambia a blanco si reviced es true
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          // Segunda palomita si no está leída
                                          if (msg.info.received == true) ...[
                                            Transform.translate(
                                              offset: Offset(-4, 0), // Ajusta la posición hacia la izquierda
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: msg.info.received == true ? Colors.white : Colors.white70, // Cambia a blanco si reviced es true
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ]


                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 4, // Ajusta la posición para que quede pegado al contenedor
                          left: isMe ? null : 10,
                          right: isMe ? 10 : null,
                          child: CustomPaint(
                            size: const Size(18, 16),
                            painter: ChatBubbleTail(isMe: isMe),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
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
                      fillColor: ColorsJunghanns.lightBlue,
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
                              onTap: () => _showAttachmentMenu(context),
                              child: const Icon(Icons.attach_file, color: ColorsJunghanns.blue, size: 27),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _takeAndSendPhoto(context),
                              child: const Icon(Icons.camera_alt, color: ColorsJunghanns.blue, size: 27),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 23,
                  backgroundColor: ColorsJunghanns.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        chatProvider.sendMessage(mensaje: controller.text, type: "T");
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
  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Evita el scroll dentro del modal
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 elementos por fila
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            children: [
              _attachmentItem(
                context,
                icon: Icons.photo,
                color: Colors.green,
                label: "Galería",
                onTap: () => _pickAndSendMedia(context),
              ),
              _attachmentItem(
                context,
                icon: Icons.insert_drive_file,
                color: Colors.blue,
                label: "Documento",
                onTap: () => _pickAndSendFile(context),
              ),
              _attachmentItem(
                context,
                icon: Icons.camera_alt,
                color: Colors.orange,
                label: "Cámara",
                onTap: () => _takeAndSendPhoto(context),
              ),
              _attachmentItem(
                context,
                icon: Icons.location_on,
                color: Colors.red,
                label: "Ubicación",
                onTap: () => _ubicationSend(context),
              ),
              _attachmentItem(
                context,
                icon: Icons.headphones_rounded,
                color: Colors.purple,
                label: "Audio",
                onTap: () =>  _pickAndSendAudio(context),
              ),
             /* _attachmentItem(
                context,
                icon: Icons.person,
                color: Colors.teal,
                label: "Contacto",
                onTap: () => {},
              ),*/
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentItem(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String label,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  // Método para seleccionar imágenes
  /*void _pickAndSendMedia(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Usar FilePicker para seleccionar imágenes y videos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // No permitir múltiples archivos, solo uno
      type: FileType.media, // Permitir seleccionar imágenes y videos
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Imprimir el archivo seleccionado para depuración
      print("📂 Archivo seleccionado: ${file.path}");

      // Llamar al Provider para enviar el archivo
      chatProvider.sendFile([file], type: "I");

      // Desplazar hacia abajo si es necesario
      _scrollToBottom();
    } else {
      print("⚠️ No se seleccionó ningún archivo.");
    }
  }*/
  void _pickAndSendMedia(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Usar FilePicker para seleccionar imágenes y videos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // No permitir múltiples archivos, solo uno
      type: FileType.media, // Permitir seleccionar imágenes y videos
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Obtener la extensión del archivo
      String extension = file.path.split('.').last.toLowerCase();

      // Determinar si es una imagen o un video basado en la extensión
      String fileType = '';
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
        fileType = 'I'; // Es una imagen
      } else if (['mp4', 'mov', 'avi', 'mkv', 'flv'].contains(extension)) {
        fileType = 'V'; // Es un video
      } else {
        fileType = 'Unknown'; // Si no es ni una imagen ni un video
      }

      // Imprimir el archivo seleccionado y el tipo para depuración
      print("📂 Archivo seleccionado: ${file.path}");
      print("Tipo de archivo: $fileType");

      // Llamar al Provider para enviar el archivo con el tipo adecuado
      chatProvider.sendFile([file], type: fileType);

      // Desplazar hacia abajo si es necesario
      _scrollToBottom();
    } else {
      print("⚠️ No se seleccionó ningún archivo.");
    }
  }

  void _pickAndSendAudio(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Solo permite seleccionar archivos de audio
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Personalizado para filtrar solo audios
      allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'm4a'], // Extensiones de audio permitidas
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      File file = File(filePath);

      print("🎵 Archivo de audio seleccionado: ${file.path}");

      // Enviar al Provider
      chatProvider.sendFile([file], type: "A");

      _scrollToBottom();
    }
    _scrollToBottom();
  }


  // Verifica si se debe mostrar la fecha
  bool _shouldDisplayDate(int index, DateTime currentDate) {
    final chatProvider = Provider.of<ChatProvider>(context);

    /*if (index == 0) {
      // Mostrar la fecha para el primer mensaje (más reciente)
      return true;
    }
*/    // Asegúrate de que el índice siguiente sea válido
    if (index + 1 >= chatProvider.chatMessages.length) {
      return false; // No mostrar la fecha para el último mensaje
    }

    // Obtener el mensaje siguiente (debido a reverse: true)
    final nextMsg = chatProvider.chatMessages[index + 1];
    DateTime nextDate = DateTime.fromMillisecondsSinceEpoch(nextMsg.registeredAt * 1000);

    // Compara solo la parte de la fecha (día, mes, año) sin la hora
    if (currentDate.year == nextDate.year &&
        currentDate.month == nextDate.month &&
        currentDate.day == nextDate.day) {
      return false; // Si las fechas son del mismo día, no mostrar la fecha
    }

    return true; // Mostrar la fecha solo si cambia
  }
  Widget _buildMessageContent(MessageModel msg) {
    if (msg.type == "T") { // Si el tipo es "T" (Texto)

      return Text(
        msg.message ?? "",
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.left,
      );
    } else if (msg.type == "I") { // Si el tipo es "I" (Imagen)
      String imageUrl = (msg.message ?? "");
      print('imageURL ${imageUrl}');
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(imageUrl: imageUrl),
            ),
          );
        },
        child: Hero(
          tag: imageUrl,
          child: Image.network(
            imageUrl,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (msg.type == "V") { // Si el tipo es "V" (Video)
      String videoUrl = (msg.message ?? "");
      return _buildVideoPlayer(videoUrl);
    } else if (msg.type == "A") { // Si el tipo es "A" (Audio)
      String audioUrl = (msg.message ?? "");
      return _buildAudioPlayer(audioUrl);
    } else if (msg.type == "F") { // Si el tipo es "F" (Archivo)
      String fileUrl = (msg.message ?? "");
      String fileName = Uri
          .parse(fileUrl)
          .pathSegments
          .last;

      return _buildFileMessage(
          fileUrl, fileName); // Llamada al método de archivo
    } else if (msg.type == 'U') {
      List<String> coords = msg.message.split(',');
      double lat = double.parse(coords[0]);
      double lng = double.parse(coords[1]);
      return GestureDetector(
        onTap: () async {
          Uri url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: Container(
          height: 150,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                IgnorePointer( // Ignora los gestos en el mapa
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(markerId: MarkerId("Ubicación"),
                          position: LatLng(lat, lng)),
                    },
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    }
    return Container();  // Para el caso en que el tipo no sea válido
  }

  void _pickAndSendFile(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false); // Obtén el Provider antes

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'doc', 'xlsx', 'docx'],  // Extensiones permitidas
    );

    if (result != null && result.files.isNotEmpty) {
      List<File> files = result.files.map((file) => File(file.path!)).toList();
      chatProvider.sendFile(files, type:"F");  // Enviar los archivos

    }
    _scrollToBottom();
  }

  /// 📸 **Tomar foto y enviarla**
  Future<void> _takeAndSendPhoto(BuildContext context) async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      List<File> files = images.map((image) => File(image.path)).toList();
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.sendFile(files);

    }
    _scrollToBottom();
  }

  Future<void> _ubicationSend(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false); // Obtiene el provider antes del await

    Position? position = await _getCurrentLocation();

    if (position != null) {
      String lat = position.latitude.toString();
      String lng = position.longitude.toString();

      print("📍 Ubicación obtenida: $lat, $lng");

      chatProvider.sendMessage(mensaje: "$lat,$lng", type:"U"); // Envía la ubicación

    }
    _scrollToBottom();
  }


  /// 🔹 **Construye el contenido del mensaje**
  Widget _buildFileMessage(String fileUrl, String fileName) {
    String fileExtension = fileName.split('.').last.toUpperCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.file_copy,
          color: Colors.white, // Color gris
          size: 30, // Tamaño del ícono
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Crear una instancia de FileDownloadAndOpen y descargar o abrir el archivo
              final fileDownloadAndOpen = FileDownloadAndOpen();
              fileDownloadAndOpen.downloadAndOpenFile(fileUrl, fileName);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[300]!, width: 1),
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
 /* void _pickAndSendFile(BuildContext context) async {
    // Seleccionar archivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);  // Permitir selección de múltiples archivos

    if (result != null && result.files.isNotEmpty) {
      // Convertir los archivos seleccionados en una lista de objetos File
      List<File> files = result.files
          .map((file) => File(file.path!))
          .toList();  // Mapear los archivos seleccionados a la lista de archivos de tipo File

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.sendFile(files);  // Enviar la lista de archivos

      _scrollToBottom();  // Desplazar hacia abajo después de enviar los archivos
    }
  }*/

  /// 🎥 **Reproductor de video**
  Widget _buildVideoPlayer(String fileUrl) {
    return WhatsAppVideoPreview(videoUrl: fileUrl);
  }

  /// 🎵 **Reproductor de audio**
  Widget _buildAudioPlayer(String fileUrl) {
    return AudioPlayerWidget(audioUrl: fileUrl);
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent + 50,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition();
  }

}

