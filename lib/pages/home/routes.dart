import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  late List<CustomerModel> customerList;
  late Size size;
  late int imageCount;
  @override
  void initState() {
    super.initState();
    customerList = [];
    imageCount=0;
    getDataCustomerList();
  }

  getDataCustomerList() async {
    customerList.clear();
    imageCount=0;
    await getListCustomer().then((answer) {
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
            customerList.add(CustomerModel.fromList(e, 10));
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    return Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: customerList
                    .map((e){
                      imageCount==3?imageCount=1:imageCount++;
                      return Column(children: [
                          RoutesCard(
                              icon: Image.asset(
                                "assets/icons/${imageCount==1?"user1":imageCount==2?"user2":"user3"}.png",
                                width: size.width * .14,
                              ),
                              customerCurrent: e,
                              title: ["${e.idClient} - ", e.address],
                              description: e.name),
                          Row(children: [
                            Container(
                              margin: EdgeInsets.only(left: (size.width * .07)+15),
                              color: ColorsJunghanns.grey,
                              width: .5,
                              height: 15,
                            )
                          ])
                        ]);})
                    .toList(),
              )
            ],
          ),
        ));
  }

  Widget header() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 10, top: 10, bottom: size.height * .08),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ruta de trabajo",
                    style: TextStyles.blue27_7,
                  ),
                  Text(
                    "  Clientes programados para visita",
                    style: TextStyles.green15_4,
                  ),
                ],
              )),
              const SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/icons/workRoute.png",
                width: size.width * .13,
              )
            ],
          )),
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 15),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lunes, 24 Junio",
                          style: TextStyles.blue19_7,
                        ),
                        Text(
                          "${customerList.length} clientes para visitar",
                          style: TextStyles.grey14_4,
                        )
                      ],
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: Decorations.orangeBorder5,
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: const TextSpan(children: [
                        TextSpan(text: "Ruta", style: TextStyles.white17_5),
                        TextSpan(text: "   10", style: TextStyles.white27_7)
                      ])))),
            ],
          )
          ),
    ]));
  }
}
