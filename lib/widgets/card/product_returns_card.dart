import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/produc_receiption.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductReturnsCard extends StatefulWidget {
  ProductReceiptionModel product;

  ProductReturnsCard({Key? key, required this.product}) : super(key: key);

  @override
  ProductReturnsCardState createState() => ProductReturnsCardState();
}

class ProductReturnsCardState extends State<ProductReturnsCard> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count = TextEditingController(text: widget.product.count.toString());
  }

  void incrementCount() {
    setState(() {
      widget.product.count++;
      count.text = widget.product.count.toString();
    });
  }

  /*void decrementCount() {
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


  void removeProduct() {
    setState(() {
      widget.product.count = 0;
      count.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    // Obtener el catálogo de productos desde el Provider

    return GestureDetector(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: Decorations.blueCard.copyWith(
              color: Decorations.blueCard.color?.withOpacity(0.3), // Aplica opacidad al color del card
            ),
            /*decoration: widget.product.count > 0
                ? Decorations.blueCard
                : Decorations.blueCard,*/
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
                        widget.product.product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.blueJ20BoldIt,
                      ),
                      const SizedBox(height: 10),
                      // Botones de +, - y delete
                      Row(
                        children: [
                          const SizedBox(width: 40),
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
                                /*IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                  onPressed: decrementCount,
                                ),*/
                                AutoSizeText(
                                  'Piezas: ${widget.product.count.toString()}',
                                  style: TextStyles.white15Itw,
                                  textAlign: TextAlign.center,
                                ),
                                /*IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  padding: const EdgeInsets.all(0),
                                  constraints: const BoxConstraints(),
                                  onPressed: incrementCount,
                                ),*/
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Etiqueta "Adicional" superpuesta
        ],
      ),
    );
  }

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
