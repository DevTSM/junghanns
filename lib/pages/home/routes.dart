import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';
import 'package:provider/provider.dart';

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  late ProviderJunghanns provider;
  late List<CustomerModel> customerList;
  late Size size;
  late int imageCount;
  @override
  void initState() {
    super.initState();
    customerList = [];
    imageCount = 0;
    getDataCustomerList();
  }

  getDataCustomerList() async {
    customerList.clear();
    imageCount = 0;
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
        provider.handler.deleteTable();
        //provider.handler.addColumn();
        answer.body.map((e) {
          setState(() {
            customerList.add(CustomerModel.fromList(e, 10));
            provider.handler.insertUser([customerList.last]);
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
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
       key: GlobalKey<ScaffoldState>(),
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menu.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: SizedBox(
          height: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                const SizedBox(
                  height: 20,
                ),
                provider.connectionStatus<4?
                Expanded(child: SingleChildScrollView(
                  child:Column(
                  children: customerList.map((e) {
                    imageCount == 3 ? imageCount = 1 : imageCount++;
                    return Column(
                      children: [
                      RoutesCard(
                          icon: Image.asset(
                            "assets/icons/${imageCount == 1 ? "user1" : imageCount == 2 ? "user2" : "user3"}.png",
                            width: size.width * .14,
                          ),
                          customerCurrent: e,
                          title: ["${e.idClient} - ", e.address],
                          description: e.name),
                      Row(children: [
                        Container(
                          margin:
                              EdgeInsets.only(left: (size.width * .07) + 15),
                          color: ColorsJunghanns.grey,
                          width: .5,
                          height: 15,
                        )
                      ])
                    ]);
                  }).toList(),
                ))):Expanded(
                  child: FutureBuilder(
        future: provider.handler.retrieveUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<CustomerModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                      children: [
                      RoutesCard(
                          icon: Image.asset(
                            "assets/icons/${imageCount == 1 ? "user1" : imageCount == 2 ? "user2" : "user3"}.png",
                            width: size.width * .14,
                          ),
                          customerCurrent: snapshot.data![index],
                          title: ["${snapshot.data![index].idClient} - ", snapshot.data![index].address],
                          description: snapshot.data![index].name),
                      Row(children: [
                        Container(
                          margin:
                              EdgeInsets.only(left: (size.width * .07) + 15),
                          color: ColorsJunghanns.grey,
                          width: .5,
                          height: 15,
                        )
                      ])
                    ]
                );
              });
          }else{
            return Container();
          }
          }))
              ],
            ),
          ),
    );
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
              /*IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorsJunghanns.blueJ,
                  )),*/
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 15),
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
                      ))),
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
          padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkDate(DateTime.now()),
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
          )),
    ]));
  }
}
