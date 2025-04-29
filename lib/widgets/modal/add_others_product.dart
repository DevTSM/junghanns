import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/widgets/select/select_product_additional.dart';
import 'package:junghanns/widgets/select/select_product_missing.dart';
import 'package:junghanns/widgets/select/select_product_others.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../button/custom_button.dart';

class AddOthersProductModal extends StatefulWidget {
  final ProviderJunghanns controller;

  const AddOthersProductModal({Key? key, required this.controller}) : super(key: key);

  @override
  _AddMissingProductModalState createState() => _AddMissingProductModalState();
}

class _AddMissingProductModalState extends State<AddOthersProductModal> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderJunghanns>(
      builder: (context, controllerUI, _) {
        final accessory = widget.controller.productCurrent;
        final selectedAccessory = controllerUI.stockProducts.firstWhere(
                (element) => element.idProduct == accessory?.idProduct,
            orElse: () => ProductModel.empty());

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Agregar Producto",
                style: Theme.of(context).textTheme.titleMedium!.
                copyWith(color: JunnyColor.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorsJunghanns.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: ColorsJunghanns.blueJ),
                                onPressed: widget.controller.productCurrent != null
                                    ? () {
                                  int currentCount = int.tryParse(
                                      widget.controller.productCurrent!.count) ??
                                      1;
                                  if (currentCount > 1) {
                                    setState(() {
                                      widget.controller.productCurrent!.count =
                                          (currentCount - 1).toString();
                                    });
                                  }
                                }
                                    : null,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                (widget.controller.productCurrent ?? ProductModel.empty()).count.toString(),
                              ),
                              const SizedBox(width: 7),
                              IconButton(
                                icon: const Icon(Icons.add, color: ColorsJunghanns.blueJ),
                                onPressed: widget.controller.productCurrent != null
                                    ? () {
                                  int currentCount = int.tryParse(widget.controller.productCurrent!.count) ?? 0;

                                  final availableStock = selectedAccessory.stock;

                                  if (currentCount < availableStock) {
                                    setState(() {
                                      widget.controller.productCurrent!.count= (currentCount + 1).toString();
                                    });
                                  }
                                }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SelectProductOthers(
                            current: controllerUI.stockProducts
                                .where((element) => element.idProduct == (widget.controller.productCurrent?.idProduct))
                                .isNotEmpty ? controllerUI.stockProducts
                                .where((element) => element.idProduct == (widget.controller.productCurrent?.idProduct))
                                .first
                                : ProductModel.empty(),
                            update: (newValue) {
                              setState(() {
                                widget.controller.productCurrent = ProductModel.fromThis(newValue!);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      onTap: widget.controller.productCurrent != null
                          ? () async {
                        // Se agrega a la lista de forma local.
                        final product = widget.controller.productCurrent!;
                        widget.controller.addMissingProduct(product, int.parse(product.count));
                        widget.controller.productCurrent = null;
                        Navigator.pop(context);
                      }
                          : () {},
                      colorDotted: ColorsJunghanns.white,
                      color: widget.controller.productCurrent != null
                          ? ColorsJunghanns.blueJ
                          : ColorsJunghanns.grey,
                      label: "Agregar",
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      radius: const BorderRadius.all(Radius.circular(30)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
