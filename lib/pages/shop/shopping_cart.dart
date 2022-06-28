import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/services/store.dart';
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
  late List<RefillModel> refillList = [];
  late List<ProductModel> productsList = [];
  late bool isSelect = true;
  late bool isProduct;

  @override
  void initState() {
    super.initState();
    isProduct = true;
    getDataProducts();
  }

  getDataProducts() async {
    await getProductList().then((answer) {
      getDataRefill();
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {}
    });
  }

  getDataRefill() async {
    await getRefillList().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        refillList.clear();
        setState(() {
          answer.body.map((e) => refillList.add(RefillModel.fromService(e))).toList();
        });
      }
    });
  }
  setitemRefill(){
    setState(() {
      isProduct=false;
    });
  }
  setitemProduct(){
    setState(() {
      isProduct=true;
    });
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
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
        body: Stack(
            children: [
              header(),
              itemList()
            ],
          ),
        );
  }

  Widget header() {
    return Container(
        color: ColorsJunghanns.green,
        padding: EdgeInsets.only(
            right: 15, left: 23, top: 10, bottom: size.height * .08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorsJunghanns.white,
                  )),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      Image.asset(
                        "assets/icons/shoppingIcon.png",
                        width: 60,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "\$0.00",
                    style: TextStyles.white40Bold,
                  )
                ],
              )),
            ],
          ),
        ]));
  }

  Widget itemList() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .18),
      padding: const EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: ButtonJunghanns(
                      isIcon: true,
                      icon: Image.asset(
                        isProduct
                            ? "assets/icons/shopP2.png"
                            : "assets/icons/shopP1.png",
                        width: size.width * 0.14,
                      ),
                      fun: setitemProduct,
                      decoration: isProduct?Decorations.blueBorder12:Decorations.whiteBorder12,
                      style: isProduct?TextStyles.white14_5:TextStyles.blue16_4,
                      label: "Productos")),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: ButtonJunghanns(
                      isIcon: true,
                      icon: Image.asset(
                          !isProduct
                              ? "assets/icons/shopR2.png"
                              : "assets/icons/shopR1.png",
                          width: size.width * 0.14),
                      fun: setitemRefill,
                      decoration: isProduct?Decorations.whiteBorder12:Decorations.blueBorder12,
                      style: isProduct?TextStyles.blue16_4:TextStyles.white14_5,
                      label: "Recargas"))
            ],
          ),
          const SizedBox(height: 20,),
          Expanded(child:Container(
                  width: size.width,
                  child: GridView.custom(
                    gridDelegate: SliverWovenGridDelegate.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 30,
                      pattern: [
                        WovenGridTile(.85),
                        WovenGridTile(.85),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) => isProduct?ProductCard(
                        image: productsList[index].img,
                        productB: productsList[index].name[0],
                        productN: productsList[index].name[1],
                        price: productsList[index].price.toString()):RefillCard(refillCurrent: refillList[index],),
                        childCount: isProduct?productsList.length:refillList.length),
                  ),
                ))
        ],
      ),
    );
  }


}
