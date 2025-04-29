import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/produc_receiption.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductOthersCard extends StatefulWidget {
  ProductReceiptionModel product;

  ProductOthersCard({Key? key, required this.product}) : super(key: key);

  @override
  ProductOthersCardState createState() => ProductOthersCardState();
}

class ProductOthersCardState extends State<ProductOthersCard> {
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
    final productCatalog = Provider.of<ProviderJunghanns>(context).productsCatalog;

    final catalogProduct = productCatalog.firstWhere(
          (catalogItem) => catalogItem.products == widget.product.id,
      orElse: () => ProductCatalogModel.empty(),
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
                Flexible(
                  flex: 3,
                  child: imageProduct(),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      AutoSizeText(
                        catalogProduct.description,
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
                                AutoSizeText(
                                  'Piezas: ${widget.product.count.toString()}',
                                  style: TextStyles.white15Itw,
                                  textAlign: TextAlign.center,
                                ),
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
