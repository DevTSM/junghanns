import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image/image.dart' as img;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Importamos para obtener la ruta del almacenamiento local
import 'package:provider/provider.dart';
import '../../components/loading.dart';
import '../../database/database_evidence.dart';
import '../../provider/provider.dart';
import '../../styles/color.dart';
import '../button/button_attencion.dart';

class Comment extends StatefulWidget {
  final Function(File? image) yesFunction;
  final File? image;
  final String current;
  final String idRuta;
  final String idCliente;
  final String tipo;
  final String cantidad;
  final double lat;
  final double lon;
  final String fechaRegistro;
  final int idAutorization;
  final String idTransaccion;

  Comment({
    super.key,
    required this.yesFunction,
    this.image,
    required this.current,
    required this.idRuta,
    required this.idCliente,
    required this.tipo,
    required this.cantidad,
    required this.lat,
    required this.lon,
    required this.fechaRegistro,
    required this.idAutorization,
    required this.idTransaccion,
  });

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController comment = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoadingOne = false;
  final DatabaseHelper dbHelper = DatabaseHelper();
  late bool imageTooLarge;
  bool isCompressing = false;


  @override
  void initState() {
    super.initState();
    isLoadingOne = false;
    imageTooLarge = false;
    print("Fecha de registro recibida: ${widget.fechaRegistro}");
  }

  // Función para capturar imagen
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Comprimir la imagen
      File compressedImage = await _compressImage(imageFile);

      // Verificar el tamaño después de la compresión
      int fileSizeInBytes = await compressedImage.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      // Obtener tamaño después de compresión
      int compressedSizeInBytes = await compressedImage.length();
      double compressedSizeInMB = compressedSizeInBytes / (1024 * 1024);
      print("Tamaño comprimido: ${compressedSizeInMB.toStringAsFixed(2)} MB");

      setState(() {
        if (fileSizeInMB > 2) {
          imageTooLarge = true;
          _imageFile = compressedImage;
        } else {
          imageTooLarge = false;
          _imageFile = compressedImage;
        }
      });
    }
  }

  Future<File> _compressImage(File file) async {
    setState(() {
      isCompressing = true;
    });

    Uint8List imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      setState(() {
        isCompressing = false;
      });
      return file;
    }

    // Redimensionar y reducir calidad
    img.Image resizedImage = img.copyResize(image, width: 800);
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 80);

    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    setState(() {
      isCompressing = false;
    });

    return compressedFile;
  }

  Future<void> _saveImageToLocalStorage(File imageFile) async {
    String filePath = ''; // Declarar filePath fuera del try

    try {
      // Imprimir ruta del directorio y archivo para debug
      final Directory appDocDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final String evidenceDirPath = '${appDocDir.path}/evidencias';
      final Directory evidenceDir = Directory(evidenceDirPath);

      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }

      final String fileName = '${widget.idAutorization}.jpg';
      final String filePath = '$evidenceDirPath/$fileName';

      // Realizar más operaciones (conectividad, base de datos, etc.)
      final String fecha = '${widget.fechaRegistro}';
      var connectivityResult = await (Connectivity().checkConnectivity());
      await dbHelper.insertEvidence(
          widget.idRuta, widget.idCliente, widget.tipo, widget.cantidad, widget.lat, widget.lon,
          widget.idAutorization, filePath, fecha, widget.idTransaccion, 0, 0
      );
      await printEvidencesFromDB();
    } catch (e, stack) {
      // Mostrar el error en un Toast con detalles
      Fluttertoast.showToast(
        msg: "Error: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}\nRuta: $filePath",
        timeInSecForIosWeb: 16,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
      // Imprimir el error y stack en consola para debugging
      print("Error al guardar la imagen: $e");
      print("StackTrace: $stack");
    }
  }


  Future<void> printEvidences() async {
    try {
      // Obtener todas las evidencias desde la base de datos
      final evidences = await dbHelper.getAllEvidences();

      // Imprimir las evidencias en la consola
      for (var evidence in evidences) {
        print("ID Ruta: ${evidence.idRuta}, ID Cliente: ${evidence.idCliente}, Tipo: ${evidence.tipo}, Cantidad: ${evidence.cantidad}, Lat: ${evidence.lat}, Lon: ${evidence.lon}, ID Autorización: ${evidence.idAutorization}, Path: ${evidence.filePath}, Date:${evidence.fechaRegistro}, Subido: ${evidence.isUploaded}, idTransaccion: ${evidence.idTransaccion}");
      }
    } catch (e) {
      print("Error al obtener evidencias: $e");
    }
  }

  Future<void> printEvidencesFromDB() async {
    try {
      // Obtener todas las evidencias desde la base de datos
      final evidences = await dbHelper.getAllEvidences();

      // Imprimir las evidencias en la consola
      for (var evidence in evidences) {
        print("ID Ruta: ${evidence.idRuta}, ID Cliente: ${evidence.idCliente}, Tipo: ${evidence.tipo}, Cantidad: ${evidence.cantidad}, Lat: ${evidence.lat}, Lon: ${evidence.lon}, ID Autorización: ${evidence.idAutorization}, Path: ${evidence.filePath}, Date:${evidence.fechaRegistro}, Subido: ${evidence.isUploaded}");
      }
    } catch (e) {
      print("Error al obtener evidencias: $e");
    }
  }


  Widget _buttons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: CustomButtonAttention(
              onTap: () async {
                setState(() {
                  isLoadingOne = true;
                });

                if (_imageFile != null) {
                  // Guardar la imagen en el almacenamiento local
                  await _saveImageToLocalStorage(_imageFile!);

                  Navigator.pop(context);
                  // Llamar a la función yesFunction
                  widget.yesFunction(_imageFile);
                }

                setState(() {
                  isLoadingOne = false;
                });
              },
              color: ColorsJunghanns.blueJ,
              label: "SI, ADELANTE",
              colorDotted: ColorsJunghanns.white,
              radius: BorderRadius.circular(10),
              width: double.infinity,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: CustomButtonAttention(
            onTap: () => Navigator.pop(context),
            color: ColorsJunghanns.red,
            label: "NO, CANCELAR",
            colorDotted: ColorsJunghanns.white,
            radius: BorderRadius.circular(10),
            width: double.infinity,
          ),
        ),
      ],
    );
  }
  Widget _buildAlert() {
    if (imageTooLarge == true) {
      print('IMPRIMIENDO EL VALO DE : ${imageTooLarge}');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              FaIcon(FontAwesomeIcons.warning, color: Colors.red, size: 25,),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Revisa la configuración y parámetros de la cámara. La imagen supera los 2MB.",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.bottleWater,
              size: 40,
              color: ColorsJunghanns.blueJ,
            ),
            const SizedBox(height: 10),
            Text(
              widget.current,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: JunnyColor.black,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Ingrese la evidencia del producto.",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: JunnyColor.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            _buildAlert(),
            const SizedBox(height: 10),
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: MediaQuery.of(context).size.width * .25,
                height: MediaQuery.of(context).size.width * .3,
              )
            else if (widget.image != null)
              Image.file(
                widget.image!,
                width: MediaQuery.of(context).size.width * .25,
                height: MediaQuery.of(context).size.width * .3,
              )
            else if (isCompressing)
                const Column(
                  children: [
                    Text(
                      "Comprimiendo imagen",
                      style: TextStyle(
                        color: ColorsJunghanns.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SpinKitCircle(
                      color: ColorsJunghanns.blue,
                      size: 30.0,
                    ),
                  ],
                )
              else
                const Text(
                  "Agrega la evidencia",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: Icon(Icons.camera_alt),
              label: Text("Capturar evidencia"),
            ),
            const SizedBox(height: 15),
            if (isLoadingOne)
              const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: LoadingJunghanns(),
                ),
              ),
            _buttons(context),
          ],
        ),
      ),
    );
  }
}

void showComment({
  required BuildContext context,
  required Function(File? image) yesFunction,
  File? image,
  required String current,
  required String idRuta,
  required String idCliente,
  required String tipo,
  required String cantidad,
  required double lat,
  required double lon,
  required int idAutorization,
  required String fechaRegistro,
  required String idTransaccion,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Comment(
        yesFunction: yesFunction,
        image: image,
        current: current,
        idRuta: idRuta,
        idCliente: idCliente,
        tipo: tipo,
        cantidad: cantidad,
        lat: lat,
        lon: lon,
        idAutorization: idAutorization,
        fechaRegistro: fechaRegistro,
        idTransaccion: idTransaccion,
      ),
    ),
  );
}
