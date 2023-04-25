// ignore_for_file: must_be_immutable
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/textfield/text_field.text.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/styles/color.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductSaleCardPriority extends StatefulWidget {
  ProductModel productCurrent;
  Function update;
  ProductSaleCardPriority(
      {Key? key, required this.productCurrent, required this.update})
      : super(key: key);

  @override
  ProductSaleCardPriorityState createState() => ProductSaleCardPriorityState();
}

class ProductSaleCardPriorityState extends State<ProductSaleCardPriority> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count=TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            width: double.infinity,
            height: size.height * 0.18,
            decoration: widget.productCurrent.number > 0
                ? Decorations.blueCard
                : Decorations.whiteJCard,
            child: Row(
              children: [
                Expanded(flex: 5, 
                child: Column(
                  children: [
                    imageProduct(),
                    const SizedBox(height: 5,),
                    Container(
                margin: const EdgeInsets.only(bottom: 2, left: 28, right: 28),
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                alignment: Alignment.center,
                decoration: Decorations.greenJCardB30,
                child: AutoSizeText(
                  "Stock: ${widget.productCurrent.stock - widget.productCurrent.number}",
                  style: TextStyles.white15Itw,
                )),
                    ])),
                Expanded(flex: 7, child: info()),
              ],
            )),
        onTap: () {
          showSelect();
        });
  }

  Widget info() {
    return Container(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Visibility(
              visible: widget.productCurrent.count!="",
              child: Flexible(flex: 3,
              child:RichText(text: TextSpan(
                  children: [
                    TextSpan(text: widget.productCurrent.count,style:TextStyles.blueJ50BoldIt ),
                    TextSpan(text: " LTS",style:TextStyles.blueJ20BoldIt)
                  ]
                )))),
            Flexible(
                child: AutoSizeText(
              widget.productCurrent.description,
              maxLines: 1,
              style: TextStyles.blueJ20BoldIt,
            )),
            
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 5),
              decoration: Decorations.white2Card,
              child: Text(
                formatMoney.format(widget.productCurrent.price),
                textAlign: TextAlign.center,
                style: TextStyles.blueJ20BoldIt,
              ),
            )
          ],
        ));
  }

  Widget imageProduct() {
    return Container(
        width: size.height * 0.1,
        height: size.height * 0.1,
        decoration: Decorations.white2Card,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.productCurrent.img))),
            ),
            widget.productCurrent.number > 0
                ? Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(top: 2, right: 2),
                        alignment: Alignment.center,
                        decoration: Decorations.greenJCardB30,
                        child: AutoSizeText(
                          widget.productCurrent.number.toString(),
                          style: TextStyles.white30SemiBold,
                        )))
                : Container()
          ],
        ));
  }

  showSelect() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    padding: const EdgeInsets.all(12),
                    width: size.width * .75,
                    decoration: Decorations.whiteS1Card,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //PRODUCTO
                        Container(
                            margin: const EdgeInsets.only(top: 8),
                            alignment: Alignment.center,
                            child: DefaultTextStyle(
                                style: TextStyles.blueJ18Bold,
                                child:
                                    Text(widget.productCurrent.description))),
                        //BOTONES
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //BOTON DE MENOS
                                GestureDetector(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.minus,
                                          size: 35,
                                          color: ColorsJunghanns.red,
                                        )),
                                    onTap: () {
                                      setState(() => widget.update(
                                          widget.productCurrent, 0));
                                          count.text= widget.productCurrent.number.toString();
                                    }),
                                    const SizedBox(width: 10,),
                                //CANTIDAD
                                Expanded(child:textField2(
                                  ontap: (){
                                    count.text= widget.productCurrent.number.toString();
                                  },
                                  (String value){
                                  if(value!=""){
                                    int? number=int.tryParse(value);
                                    if((number??1)<widget.productCurrent.stock&&(number??1)>0){
                                    setState(() => widget.productCurrent.setCount((number??1)));
                                    widget.update(
                                          widget.productCurrent, 2);
                                  }else{
                                     setState(() => widget.productCurrent.setCount(widget.productCurrent.stock));
                                    widget.update(
                                          widget.productCurrent, 2);
                                  }
                                  
                                  }
                                },count, "",type: TextInputType.number)),
                                const SizedBox(width: 10,),

                                //BOTON DE MAS
                                GestureDetector(
                                    onTap: widget.productCurrent.stock !=
                                                widget.productCurrent.number ||
                                            widget.productCurrent.type == 2
                                        ? () {
                                            setState(() => widget.update(
                                                widget.productCurrent, 1));
                                                count.text= widget.productCurrent.number.toString();
                                          }
                                        : () {},
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.plus,
                                          size: 35,
                                          color: ColorsJunghanns.greenJ,
                                        )))
                              ],
                            )),

                        GestureDetector(
                          child: Container(
                            decoration: Decorations.blueBorder12,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            alignment: Alignment.center,
                            child: const Text(
                              "CONFIRMAR",
                              style: TextStyles.white17_5,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                )));
  }
}

class ProductSaleCard extends StatefulWidget {
  ProductModel productCurrent;
  Function update;
  bool isRefill;
  ProductSaleCard(
      {Key? key,
      required this.productCurrent,
      required this.update,
      this.isRefill = false})
      : super(key: key);

  @override
  ProductSaleCardState createState() => ProductSaleCardState();
}

class ProductSaleCardState extends State<ProductSaleCard> {
  var myGroup = AutoSizeGroup();
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(13),
            decoration: widget.productCurrent.number > 0
                ? Decorations.blueCard
                : Decorations.whiteJCard,
            child: Column(
              children: [
                Expanded(flex: 9, child: imageProduct()),
                Expanded(
                  flex: 2,
                  child: AutoSizeText(
                    widget.productCurrent.description,
                    maxLines: 1,
                    group: myGroup,
                    style: TextStyles.blueJ20BoldIt,
                  ),
                ),
                Visibility(
                    visible: !widget.isRefill,
                    child: Expanded(
                        flex: 2,
                        child: Container(
                            margin: const EdgeInsets.only(
                                bottom: 2, left: 24, right: 24),
                            alignment: Alignment.center,
                            decoration: Decorations.greenJCardB30,
                            child: AutoSizeText(
                              "Stock: ${widget.productCurrent.stock - widget.productCurrent.number}",
                              style: TextStyles.white15Itw,
                            )))),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.only(top: 2, bottom: 2),
                    alignment: Alignment.center,
                    child: Text(
                      formatMoney.format(widget.productCurrent.price),
                      style: TextStyles.blueJ20BoldIt,
                    ),
                  ),
                ),
              ],
            )),
        onTap: () {
          showSelect();
        });
  }

  Widget imageProduct() {
    return Container(
        width: double.infinity,
        decoration: Decorations.white2Card,
        margin: const EdgeInsets.only(bottom: 2),
        child: Stack(
          children: [
            widget.productCurrent.type == 1
                ? Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.productCurrent.img))),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      widget.productCurrent.img,
                      fit: BoxFit.contain,
                    ),
                  ),
            widget.productCurrent.number > 0 && !widget.isRefill
                ? Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(top: 2, right: 2),
                        alignment: Alignment.center,
                        decoration: Decorations.greenJCardB30,
                        child: AutoSizeText(
                          widget.productCurrent.number.toString(),
                          style: TextStyles.white30SemiBold,
                        )))
                : Container()
          ],
        ));
  }

  Widget textP() {
    return Container(
        margin: const EdgeInsets.only(top: 8),
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.blueJ18Bold,
            child: Text(widget.productCurrent.description)));
  }

  showSelect() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    padding: const EdgeInsets.all(12),
                    width: MediaQuery.of(context).size.width * .75,
                    decoration: Decorations.whiteS1Card,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //PRODUCTO
                        textP(),

                        //BOTONES
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //BOTON DE MENOS
                                GestureDetector(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.minus,
                                          size: 35,
                                          color: ColorsJunghanns.red,
                                        )),
                                    onTap: () {
                                      setState(() => widget.update(
                                          widget.productCurrent, 0));
                                    }),

                                //CANTIDAD
                                DefaultTextStyle(
                                  style: TextStyles.greenJ30Bold,
                                  child: Text(
                                    widget.productCurrent.number.toString(),
                                  ),
                                ),

                                //BOTON DE MAS
                                GestureDetector(
                                    onTap: widget.productCurrent.stock !=
                                                widget.productCurrent.number ||
                                            widget.productCurrent.type == 2
                                        ? () {
                                            setState(() => widget.update(
                                                widget.productCurrent, 1));
                                          }
                                        : () {},
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.plus,
                                          size: 35,
                                          color: ColorsJunghanns.greenJ,
                                        )))
                              ],
                            )),

                        GestureDetector(
                          child: Container(
                            decoration: Decorations.blueBorder12,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            alignment: Alignment.center,
                            child: const Text(
                              "CONFIRMAR",
                              style: TextStyles.white17_5,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                )));
  }
}
