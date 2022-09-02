import 'package:flutter/material.dart';
import 'package:junghanns/components/app_bar.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/pages/home/call.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/pages/home/new_customer.dart';
import 'package:junghanns/pages/home/routes.dart';
import 'package:junghanns/pages/home/second.dart';
import 'package:junghanns/pages/home/specials.dart';

const List<Widget> pages = [
  Home(),
  Specials(),
  Routes(),
  Seconds(),
  Call(),
  //Home()
  NewCustomer()
];

class HomePrincipal extends StatefulWidget {
  int index;
  HomePrincipal({Key? key, this.index = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePrincipalState();
}

class _HomePrincipalState extends State<HomePrincipal> {
  late Size size;
  late int indexCurrent;
  @override
  void initState() {
    super.initState();
    indexCurrent = widget.index;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setIndexCurrent(int current) {
    setState(() {
      indexCurrent = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    return Scaffold(
      appBar: appBarJunghanns(context, size),
      body: pages[indexCurrent],
      bottomNavigationBar: bottomBar(setIndexCurrent, indexCurrent),
    );
  }
}
