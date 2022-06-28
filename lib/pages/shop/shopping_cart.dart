import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';

import '../../widgets/card/refill_card.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({Key? key}) : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late Size size;
  late List<RefillCard> refillList = [];
  late List<ProductCard> productsList = [];
  late bool isSelect = true;

  @override
  void initState() {
    super.initState();

    productsList.add(const ProductCard(
        image: "assets/images/Ceramica.JPG",
        productB: "Cerámica ",
        productN: "M12 Bco",
        price: "\$360.00"));
    productsList.add(const ProductCard(
        image: "assets/images/Garrafon.JPG",
        productB: "Liquido ",
        productN: "20L",
        price: "\$43.00"));
    productsList.add(const ProductCard(
        image: "assets/images/Ceramica.JPG",
        productB: "Cerámica ",
        productN: "M12 Bco",
        price: "\$360.00"));
    productsList.add(const ProductCard(
        image: "assets/images/Garrafon.JPG",
        productB: "Garrafón nuevo",
        productN: "",
        price: "\$43.00"));

    refillList
        .add(const RefillCard(icon: "assets/icons/refill1.png", number: 100));
    refillList
        .add(const RefillCard(icon: "assets/icons/refill2.png", number: 200));
    refillList
        .add(const RefillCard(icon: "assets/icons/refill3.png", number: 300));
    refillList
        .add(const RefillCard(icon: "assets/icons/refill4.png", number: 500));
    refillList
        .add(const RefillCard(icon: "assets/icons/refill5.png", number: 1000));

    getDataProductsAndRefillList();
  }

  getDataProductsAndRefillList() async {
    await getListProductsAndRefill().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        answer.body.map((e) {
          setState(() {
            log(e);
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorsJunghanns.greenJ,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: ColorsJunghanns.greenJ,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light),
          leading: GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(left: 24),
                child: Image.asset("assets/icons/menuWhite.png")),
            onTap: () {},
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            total(),
            options(),
            isSelect ? menuProducts() : menuRefill()
          ],
        ));
  }

  Widget total() {
    return Container(
      width: size.width,
      height: size.height * 0.22,
      color: ColorsJunghanns.greenJ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 8, top: 10),
                child: Text(
                  "00",
                  style: TextStyles.white24SemiBoldIt,
                ),
              ),
              Image.asset("assets/icons/shoppingIcon.png")
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "\$0.00",
              style: TextStyles.white40Bold,
            ),
          )
        ],
      ),
    );
  }

  Widget options() {
    return SizedBox(
        width: size.width,
        height: size.height * 0.08,
        child: Stack(
          children: [
            optionsBackground(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                optionProduct(),
                optionRefill(),
              ],
            ),
          ],
        ));
  }

  Widget optionsBackground() {
    return Column(
      children: [
        Container(height: size.height * 0.04, color: ColorsJunghanns.green),
        Container(height: size.height * 0.04)
      ],
    );
  }

  Widget optionProduct() {
    return GestureDetector(
      child: Container(
        width: size.width * 0.44,
        height: size.height * 0.08,
        decoration:
            isSelect ? Decorations.blueBorder12 : Decorations.whiteS1Card,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.14,
              child: Image.asset(
                isSelect
                    ? "assets/icons/shopP2.png"
                    : "assets/icons/shopP1.png",
              ),
            ),
            SizedBox(
              child: AutoSizeText(
                "Productos",
                style: isSelect
                    ? TextStyles.white18SemiBoldIt
                    : TextStyles.blue18SemiBoldIt,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        if (!isSelect) {
          setState(() {
            isSelect = !isSelect;
          });
        }
      },
    );
  }

  Widget optionRefill() {
    return GestureDetector(
      child: Container(
        width: size.width * 0.44,
        height: size.height * 0.08,
        decoration:
            !isSelect ? Decorations.blueBorder12 : Decorations.whiteS1Card,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.15,
              child: Image.asset(
                !isSelect
                    ? "assets/icons/shopR2.png"
                    : "assets/icons/shopR1.png",
              ),
            ),
            SizedBox(
              child: AutoSizeText(
                "Recargas",
                style: !isSelect
                    ? TextStyles.white18SemiBoldIt
                    : TextStyles.blue18SemiBoldIt,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        if (isSelect) {
          setState(() {
            isSelect = !isSelect;
          });
        }
      },
    );
  }

  Widget menuProducts() {
    return Flexible(
        child: Container(
            padding: const EdgeInsets.all(15),
            child: StaggeredGridView.countBuilder(
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              crossAxisCount: 2,
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                return productsList[index];
              },
              staggeredTileBuilder: (int index) =>
                  const StaggeredTile.count(1, 1.3),
            )));
  }

  Widget menuRefill() {
    return Flexible(
        child: Container(
            padding: const EdgeInsets.all(15),
            child: StaggeredGridView.countBuilder(
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              crossAxisCount: 2,
              itemCount: refillList.length,
              itemBuilder: (context, index) {
                return refillList[index];
              },
              staggeredTileBuilder: (int index) =>
                  const StaggeredTile.count(1, 1),
            )));
  }
}
