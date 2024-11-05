import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductMissingCard extends StatefulWidget {
  ProductModel product;

  ProductMissingCard({Key? key, required this.product}) : super(key: key);

  @override
  ProductMissingCardState createState() => ProductMissingCardState();
}

class ProductMissingCardState extends State<ProductMissingCard> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count = TextEditingController(text: widget.product.count.toString());
  }

  /*void incrementCount() {
    setState(() {
      widget.product.count++;
      count.text = widget.product.count.toString();
    });
  }

  void decrementCount() {
    if (widget.product.count > 0) {
      setState(() {
        widget.product.count--;
        count.text = widget.product.count.toString();
        if (widget.product.count == 0) {
          context.read<ProviderJunghanns>().removeAdditionalProduct(widget.product);
        }
      });
    }
  }*/


  /*void removeProduct() {
    setState(() {
      widget.product.count = 0;
      count.text = '0';
    });
  }*/
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final selectedAccessory = providerJunghanns.stockProducts.firstWhere(
          (element) => element.idProduct == widget.product?.idProduct,
      orElse: () => ProductModel.empty(),
    );

    return GestureDetector(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: Decorations.blueCard.copyWith(
              color: Decorations.blueCard.color?.withOpacity(0.3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen a la izquierda
                Flexible(
                  flex: 3,
                  child: imageProduct(),
                ),
                const SizedBox(width: 10),
                // Descripción y controles a la derecha
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      AutoSizeText(
                        widget.product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.blueJ20BoldIt,
                      ),
                      const SizedBox(height: 10),
                      // Controles de cantidad
                      Row(
                        children: [
                          const SizedBox(width: 3),
                          Container(
                            width: size.width * 0.35,
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            alignment: Alignment.center,
                            decoration: Decorations.greenJCardB30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.product.idProduct != 22 && widget.product.idProduct != 21) ...[
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.white),
                                    padding: const EdgeInsets.all(0),
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      int currentCount = int.tryParse(widget.product.count) ?? 0; // Convertir el valor a int
                                      if (currentCount > 0) {
                                        providerJunghanns.updateMissingProduct(widget.product, -1);
                                      }
                                    },
                                  ),
                                ],
                                AutoSizeText(
                                  widget.product.count.toString(),
                                  style: TextStyles.white15Itw,
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.product.idProduct == 22 ||widget.product.idProduct == 21) ...[
                                  const SizedBox(width: 4), // Espacio entre el contador y el texto
                                  AutoSizeText(
                                    "Pieza(s)",
                                    style: TextStyles.white15Itw,
                                  ),
                                ],
                                if (widget.product.idProduct != 22 && widget.product.idProduct != 21) ...[
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    padding: const EdgeInsets.all(0),
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      providerJunghanns.updateMissingProduct(widget.product, 1);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Ícono de eliminar fuera del contenedor verde
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () {
                              int? productCount = int.tryParse(widget.product.count); // Convierte a int
                              if (productCount != null) { // Verifica si la conversión fue exitosa
                                context.read<ProviderJunghanns>().removeMissingProduct(widget.product, productCount);
                              }
                            },
                            padding: const EdgeInsets.all(0),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Etiqueta "Faltante" superpuesta
          if (widget.product.label == "Faltante")
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const AutoSizeText(
                  "Faltante",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final selectedAccessory = providerJunghanns.stockProducts.firstWhere(
            (element) => element.idProduct == widget.product?.idProduct,
        orElse: () => ProductModel.empty());
    return GestureDetector(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: Decorations.blueCard.copyWith(
              color: Decorations.blueCard.color?.withOpacity(0.3), // Aplica opacidad al color del card
            ),
            *//*decoration: widget.product.count > 0
                ? Decorations.blueCard
                : Decorations.blueCard,*//*
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen a la izquierda
                Flexible(
                  flex: 3,
                  child: imageProduct(),
                ),
                const SizedBox(width: 10),
                // Descripción y controles a la derecha
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      AutoSizeText(
                        widget.product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.blueJ20BoldIt,
                      ),
                      const SizedBox(height: 10),
                      // Botones de +, - y delete
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Container(
                            width: size.width * 0.35,
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            alignment: Alignment.center,
                            decoration: Decorations.greenJCardB30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    int currentCount = int.tryParse(widget.product.count) ?? 0; // Convertir el valor a int
                                    if (currentCount > 0) {
                                      providerJunghanns.updateMissingProduct(widget.product, -1);
                                    }
                                  },

                                ),
                                AutoSizeText(
                                  widget.product.count.toString(),
                                  style: TextStyles.white15Itw,
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    providerJunghanns.updateMissingProduct(widget.product, 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Ícono de eliminar fuera del contenedor verde
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () {
                              int? productCount = int.tryParse(widget.product.count); // Convierte a int
                              if (productCount != null) { // Verifica si la conversión fue exitosa
                                context.read<ProviderJunghanns>().removeMissingProduct(widget.product, productCount);
                              }
                            },
                            padding: const EdgeInsets.all(0),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      )

                      *//*Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              alignment: Alignment.center,
                              decoration: Decorations.greenJCardB30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    onPressed: decrementCount,
                                  ),

                                  AutoSizeText(
                                    widget.product.count.toString(),
                                    style: TextStyles.white15Itw,
                                    textAlign: TextAlign.center,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    onPressed: incrementCount,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Ícono de eliminar fuera del contenedor verde
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: removeProduct,
                          ),
                        ],
                      ),*//*
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Etiqueta "Adicional" superpuesta
          if (widget.product.label == "Faltante")
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const AutoSizeText(
                  "Faltante",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }*/

  /*@override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: widget.product.count > 0
                ? Decorations.blueCard
                : Decorations.blueCard,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen a la izquierda
                Flexible(
                  flex: 3,
                  child: imageProduct(),
                ),
                const SizedBox(width: 10),
                // Descripción y controles a la derecha
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.product.description,
                        maxLines: 1,
                        style: TextStyles.blueJ20BoldIt,
                      ),
                      const SizedBox(height: 10),
                      // Botones de +, - y delete
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.center,
                        decoration: Decorations.greenJCardB30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: decrementCount,
                            ),
                            AutoSizeText(
                              widget.product.count.toString(),
                              style: TextStyles.white15Itw,
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: incrementCount,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: removeProduct,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Etiqueta "Adicional" superpuesta
          if (widget.product.label == "Adicional")
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const AutoSizeText(
                  "Adicional",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }*/

  Widget imageProduct() {
    return Container(
      width: size.width * 0.3, // Ajustar el tamaño de la imagen
      height: size.height * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.product.img,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
