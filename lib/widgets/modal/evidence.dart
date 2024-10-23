/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';  // Importamos image_picker
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';
import '../../components/loading.dart';
import '../../styles/text.dart';
import '../button/button_attencion.dart';

class Comment extends StatefulWidget {
  final Function(File? image) yesFunction; // Modificamos la función para aceptar imagen
  final File? image;
  final String current;
  final String idRuta; // Nuevos datos que se pasarán al provider
  final String idCliente;
  final String tipo;
  final String cantidad;
  final double lat;
  final double lon;
  final int idAutorization;

  Comment({
    super.key,
    required this.yesFunction,
    this.image,
    required this.current,
    required this.idRuta, // Pasamos nuevos parámetros al constructor
    required this.idCliente,
    required this.tipo,
    required this.cantidad,
    required this.lat,
    required this.lon,
    required this.idAutorization,
  });

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController comment = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker(); // Instancia del picker para tomar fotos
  bool isLoadingOne = false;

  // Función para capturar imagen
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Actualizamos la imagen tomada
      });
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
              onTap: () {
                setState(() {
                  isLoadingOne = true; // Activar el estado de carga
                });

                if (_imageFile != null) {
                  // Accedemos al provider y llamamos a submitDirtyBroken
                  context.read<ProviderJunghanns>().submitDirtyBroken(
                    idRuta: widget.idRuta,
                    idCliente: widget.idCliente,
                    tipo: widget.tipo,
                    cantidad: widget.cantidad,
                    lat: widget.lat,
                    lon: widget.lon,
                    idAutorization: widget.idAutorization,
                    archivo: _imageFile!,
                  );

                  // Llamamos también a la función yesFunction si es necesario
                  widget.yesFunction(_imageFile);
                }

                setState(() {
                  isLoadingOne = false; // Activar el estado de carga
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
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: Icon(Icons.camera_alt),
              label: Text("Capturar evidencia"),
            ),
            const SizedBox(height: 15),
            _buttons(context),
            //Verificar si esta biena ahì o no
            // Indicador de carga
            Visibility(
              visible: isLoadingOne, // Mostrar solo cuando isLoadingOne sea true
              child: const Center(
                child: LoadingJunghanns(),
              ),
            ),
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
      ),
    ),
  );
}

*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Importamos para obtener la ruta del almacenamiento local
import 'package:provider/provider.dart';
import '../../components/loading.dart';
import '../../provider/provider.dart';
import '../../styles/color.dart';
import '../../styles/text.dart';
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
  final int idAutorization;

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
    required this.idAutorization,
  });

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController comment = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoadingOne = false;

  @override
  void initState() {
    super.initState();
    isLoadingOne = false;
  }

  // Función para capturar imagen
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Función para guardar la imagen en la carpeta "evidencias"
  Future<void> _saveImageToLocalStorage(File imageFile) async {
    try {
      // Obtener el directorio donde guardaremos la imagen
      final Directory appDocDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final String evidenceDirPath = '${appDocDir.path}/evidencias';
      final Directory evidenceDir = Directory(evidenceDirPath);

      // Crear la carpeta "evidencias" si no existe
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }

      // Guardar la imagen con el nombre basado en idAutorization
      final String fileName = '${widget.idAutorization}.jpg';
      final String filePath = '$evidenceDirPath/$fileName';
      final File savedImage = await imageFile.copy(filePath);

      // Confirmación de guardado
      print("Imagen guardada en: $filePath");
    } catch (e) {
      print("Error al guardar la imagen: $e");
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

                  // Llamamos al provider y submitDirtyBroken
                  context.read<ProviderJunghanns>().submitDirtyBroken(
                    idRuta: widget.idRuta,
                    idCliente: widget.idCliente,
                    tipo: widget.tipo,
                    cantidad: widget.cantidad,
                    lat: widget.lat,
                    lon: widget.lon,
                    idAutorization: widget.idAutorization,
                    archivo: _imageFile!,
                  );

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
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: Icon(Icons.camera_alt),
              label: Text("Capturar evidencia"),
            ),
            const SizedBox(height: 15),
            Visibility(
              visible: isLoadingOne,
              child: const Center(
                child: LoadingJunghanns(),
              ),
            ),
            _buttons(context),
            Visibility(
              visible: isLoadingOne,
              child: const Center(
                child: LoadingJunghanns(),
              ),
            ),
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
      ),
    ),
  );
}
