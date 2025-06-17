import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/operation_customer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/sales.dart';
import 'package:provider/provider.dart';

class Devoluciones extends StatefulWidget {
  const Devoluciones({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DevolucionesState();
}

class _DevolucionesState extends State<Devoluciones> {
  late List<OperationCustomerModel> devolucionesList;
  late TextEditingController searchTo;
  late ProviderJunghanns provider;
  late String valueSearch;
  late Size size;
  late bool isLoading;
  late bool isLoadingOne;

  @override
  void initState() {
    super.initState();
    devolucionesList = [];
    searchTo = TextEditingController();
    valueSearch = "";
    isLoading = false;
    isLoadingOne = false;
    getDevoluciones();
  }

  getDevoluciones() async {
    devolucionesList.clear();
    setState(()=> isLoading = true);
    await handler.retrieveDevolucion().then((value){
      setState(()=> isLoading = false);
      setState(()=>
      devolucionesList = 
        value.map((e) => OperationCustomerModel.fromDataBase(e)).toList()
      );
    });
  }
  
  getFilter(OperationCustomerModel current) {
    if (current.description.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (current.folio.toString().contains(valueSearch)) {
      return true;
    }
    if (valueSearch == "") {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          backgroundColor: ColorsJunghanns.whiteJ,
          systemOverlayStyle: const SystemUiOverlayStyle (
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark
          ),
          elevation: 0,
          leading: isLoading
            ? null
            : IconButton (
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: ColorsJunghanns.blue,
              )
            )
        ),
        body: RefreshIndicator(
            color: JunnyColor.blueA1,
          onRefresh: ()=> getDevoluciones(),
            child: isLoading
                ? const Center(
                  child: LoadingJunghanns(),
                )
                : SingleChildScrollView(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height + 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header(),
                            buscador(),
                            const SizedBox(
                              height: 15,
                            ),
                            devolucionesList.isEmpty?empty(context):Expanded(
                                child: SingleChildScrollView(
                                    child: Column(
                              children: devolucionesList.map((e) => 
                                getFilter(e)
                                  ? OperationsCard(
                                    current: e,
                                    update:(){},
                                    currentClient:CustomerModel.fromState(),
                                    onlyView: true,
                                  )
                                  : const SizedBox.shrink()).toList(),
                            )))
                          ],
                        )),
                  )),
      ),
      Visibility(
          visible: isLoadingOne,
          child: const Center(
            child: LoadingJunghanns(),
          ))
    ]);
  }

  Widget buscador() {
    return Container(
        height: size.height * 0.06,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: TextFormField(
            controller: searchTo,
            onChanged: (value) => setState(() {
                  valueSearch = value.toLowerCase();
                }),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blueJ15SemiBold,
            decoration: InputDecoration(
              hintText: "Buscar ...",
              hintStyle: TextStyles.grey15Itw,
              filled: true,
              fillColor: ColorsJunghanns.whiteJ,
              contentPadding: const EdgeInsets.only(left: 24),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(width: 1, color: ColorsJunghanns.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.search,
                    color: ColorsJunghanns.blue,
                  )),
            )));
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 15, top: 10, bottom: size.height * .06),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ruta de trabajo",
                style: TextStyles.blue27_7,
              ),
              Text(
                "  Devoluciones",
                style: TextStyles.green15_4,
              ),
            ],
          )),
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkDate(DateTime.now()),
                      style: JunnyText.bluea4(FontWeight.w700, 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: JunnyDecoration.orange255(8),
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: prefs.nameRouteD,
                            style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
  }
}
