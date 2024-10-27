import 'package:flutter/material.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

class SelectProductAdditional extends StatelessWidget {
  final ProductCatalogModel? current;
  final Function(ProductCatalogModel? newValue) update;

  const SelectProductAdditional({super.key, this.current, required this.update});

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
              child: DropdownButton<ProductCatalogModel?>(
                isExpanded: true,
                hint: const Text(
                  "Selecciona una opción",
                  overflow: TextOverflow.ellipsis,
                ),
                value: current,
                icon: Icon(Icons.arrow_drop_down, color: ColorsJunghanns.blueJ, size: 35),
                items: controller.accesories
                    .map((ProductCatalogModel item) {
                  return DropdownMenuItem<ProductCatalogModel>(
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
