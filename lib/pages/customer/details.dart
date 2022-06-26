import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';

class DetailsCustomer extends StatefulWidget {
  CustomerModel customerCurrent;
  DetailsCustomer({Key? key, required this.customerCurrent}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailsCustomerState();
}

class _DetailsCustomerState extends State<DetailsCustomer> {
  late Size size;
  @override
  void initState() {
    super.initState();
    getDataCustomerList();
  }

  getDataCustomerList() async {
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
          setState(() {});
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.blue,
        elevation: 0,
        leading: Icon(Icons.menu),
      ),
      body: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )),
    );
  }

  Widget header() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.blue,
          padding: EdgeInsets.only(
              right: 15, left: 23, top: 10, bottom: size.height * .08),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_ios,color: ColorsJunghanns.white,),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.customerCurrent.id}",
                    style: TextStyles.green17_4,
                  ),
                  Text(
                    widget.customerCurrent.name,
                    style: TextStyles.white17_6,
                  ),
                  
                ],
              )),
              const SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/icons/photo.png",
                width: size.width * .13,
              )
            ],
          )),
    ]));
  }
}
