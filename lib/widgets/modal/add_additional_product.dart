import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/models/product_catalog.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/widgets/select/select_product_additional.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../button/custom_button.dart';

class AddAdditionalProductModal extends StatefulWidget {
  final ProviderJunghanns controller;

  const AddAdditionalProductModal({Key? key, required this.controller}) : super(key: key);

  @override
  _AddAdditionalProductModalState createState() => _AddAdditionalProductModalState();
}

class _AddAdditionalProductModalState extends State<AddAdditionalProductModal> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderJunghanns>(
      builder: (context, controllerUI, _) {
        final accessory = widget.controller.accesoryCurrent;
        final selectedAccessory = controllerUI.productsCatalog.firstWhere(
                (element) => element.products == accessory?.products,
            orElse: () => ProductCatalogModel.empty());

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
                "Agregar Producto Adicional",
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
                                onPressed: widget.controller.accesoryCurrent != null
                                    ? () {
                                  if (widget.controller.accesoryCurrent!.count > 1) {
                                    setState(() => widget.controller.accesoryCurrent!.count--);
                                  }
                                }
                                    : null,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                (widget.controller.accesoryCurrent ?? ProductCatalogModel.empty()).count.toString(),
                              ),
                              const SizedBox(width: 7),
                              IconButton(
                                icon: const Icon(Icons.add, color: ColorsJunghanns.blueJ),
                                onPressed: widget.controller.accesoryCurrent != null
                                    ? () => setState(() => widget.controller.accesoryCurrent!.count++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SelectProductAdditional(
                            current: controllerUI.accesories.where((element) => element.products == (widget.controller.accesoryCurrent ?? ProductCatalogModel.empty()).products).firstOrNull,
                            update: (newValue) {
                              setState(() {
                                widget.controller.accesoryCurrent = ProductCatalogModel.fromThis(newValue!);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      onTap: widget.controller.accesoryCurrent != null
                          ? () async {
                        // Se agrega a la lista de forma local.
                        widget.controller.addAdditionalProduct(widget.controller.accesoryCurrent!);
                        widget.controller.accesoryCurrent = null;
                        Navigator.pop(context);
                      }
                          : () {},
                      colorDotted: ColorsJunghanns.white,
                      color: widget.controller.accesoryCurrent != null
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
