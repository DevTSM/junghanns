import 'package:flutter/material.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

class SelectProductMissing extends StatelessWidget {
  final ProductModel current;
  final Function(ProductModel? newValue) update;

  const SelectProductMissing({super.key, required this.current, required this.update});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderJunghanns>(
      builder: (context, controller, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: ColorsJunghanns.grey),
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: Container(
              child: DropdownButton<ProductModel?>(
                isExpanded: true,
                hint: const Text(
                  "Selecciona una opción",
                  overflow: TextOverflow.ellipsis,
                ),
                  value: current != null && controller.stockProducts.any((item) => item.idProduct == current!.idProduct)
                      ? current
                      : null,
                icon: Icon(Icons.arrow_drop_down, color: ColorsJunghanns.blueJ, size: 35),
                items: controller.stockProducts
                    .where((item) => item.stock > 0)
                    .map((ProductModel item){
                  return DropdownMenuItem<ProductModel>(
                    value: item,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        item.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: update,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
