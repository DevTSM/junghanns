import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';
import '../../styles/color.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';
import '../button/button_attencion.dart';

class ProductTransfersCard extends StatefulWidget {
  ProductModel product;

  ProductTransfersCard({Key? key, required this.product}) : super(key: key);

  @override
  ProductTransfersCardState createState() => ProductTransfersCardState();
}

class ProductTransfersCardState extends State<ProductTransfersCard> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count = TextEditingController(text: widget.product.count.toString());
  }
  bool isSpecialProduct(int id) {
    return [22, 21, 136, 125, 50].contains(id);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dismissible(
      key: ValueKey(widget.product.idProduct),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 40), // Ícono más grande
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, size: 40, color: ColorsJunghanns.red),
                const SizedBox(height: 10),
                Text(
                  'Confirmar eliminación',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: ColorsJunghanns.blueJ,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Deseas eliminar este producto?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonAttention(
                    onTap: () => Navigator.of(context).pop(true),
                    color: ColorsJunghanns.blueJ,
                    label: "SI, ELIMINAR",
                    colorDotted: ColorsJunghanns.white,
                    radius: BorderRadius.circular(10),
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonAttention(
                    onTap: () => Navigator.of(context).pop(false),
                    color: ColorsJunghanns.red,
                    label: "NO, CANCELAR",
                    colorDotted: ColorsJunghanns.white,
                    radius: BorderRadius.circular(10),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onDismissed: (direction) {
        int? productCount = int.tryParse(widget.product.count);
        if (productCount != null) {
          context.read<ProviderJunghanns>().removeTransfersProduct(widget.product, productCount);
        }
      },
      child: cardContent(size),
    );
  }
  Widget cardContent(Size size) {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final selectedAccessory = providerJunghanns.stockProducts.firstWhere(
          (element) => element.idProduct == widget.product.idProduct,
      orElse: () => ProductModel.empty(),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: Decorations.blueCard.copyWith(
        color: Decorations.blueCard.color?.withOpacity(0.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(flex: 3, child: imageProduct()),
          const SizedBox(width: 10),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Añadido para centrar el Container
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
                          if (!isSpecialProduct(widget.product.idProduct)) ...[
                            Transform.translate(
                              offset: const Offset(0, -4.0),
                              child: IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  int currentCount = int.tryParse(widget.product.count) ?? 0;
                                  if (currentCount > 0) {
                                    providerJunghanns.updateTransferProduct(widget.product, -1);
                                  }
                                },
                              ),
                            ),
                          ],
                          AutoSizeText(widget.product.count.toString(), style: TextStyles.white15Itw),
                          if (isSpecialProduct(widget.product.idProduct)) ...[
                            const SizedBox(width: 4),
                            AutoSizeText("Pieza(s)", style: TextStyles.white15Itw),
                          ],
                          if (!isSpecialProduct(widget.product.idProduct)) ...[
                            Transform.translate(
                              offset: const Offset(0, -4.0), // Mueve el icono hacia arriba (ajusta el valor negativo)
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  providerJunghanns.updateTransferProduct(widget.product, 1);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget imageProduct() {
    final size = MediaQuery.of(context).size; // ← Esto soluciona el error

    return Container(
      width: size.width * 0.3,
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
