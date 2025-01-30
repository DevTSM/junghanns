class CarboyModel {
  int empty;
  int full;
  int brokenCte;
  int dirtyCte;
  int brokenRoute;
  int dirtyRoute;
  int aLongWay;
  int loan;
  int pLoan;
  //String test;
  int badTaste;
  int transferLiquid;

  CarboyModel({
    required this.empty,
    required this.full,
    required this.brokenCte,
    required this.dirtyCte,
    required this.brokenRoute,
    required this.dirtyRoute,
    required this.aLongWay,
    required this.loan,
    required this.pLoan,
    //required this.test,
    required this.badTaste,
    required this.transferLiquid,
  });

  factory CarboyModel.empty() {
    return CarboyModel(
      empty: 1,
      full: 1,
      brokenCte: 1,
      dirtyCte: 1,
      brokenRoute: 1,
      dirtyRoute: 1,
      aLongWay: 1,
      loan: 1,
      pLoan: 1,
      //test: '',
      badTaste: 1,
      transferLiquid: 1,
    );
  }

  factory CarboyModel.from(Map<String, dynamic> data) {
    return CarboyModel(
      empty: int.parse((data["vacios"] ?? 0).toString()),
      full: int.parse((data["llenos"] ?? 0).toString()),
      brokenCte: int.parse((data["rotos_cte"] ?? 0).toString()),
      dirtyCte: int.parse((data["sucios_cte"] ?? 0).toString()),
      brokenRoute: int.parse((data["rotos_ruta"] ?? 0).toString()),
      dirtyRoute: int.parse((data["sucios_ruta"] ?? 0).toString()),
      aLongWay: int.parse((data["a_la_par"] ?? 0).toString()),
      loan:  int.parse((data["comodato"] ?? 0).toString()),
      pLoan:  int.parse((data["prestamo"] ?? 0).toString()),
      //test: data["test"] ?? "",
      badTaste: int.parse((data["mal_sabor"] ?? 0).toString()),
      transferLiquid: int.parse((data["liquido_20"] ?? 0).toString()),
    );
  }
  Map<String, dynamic> toPostCarboyJson() {
    return {
      'vacios': empty,
      'llenos': full,
      'rotos_cte': brokenCte,
      'sucios_cte': dirtyCte,
      'rotos_ruta': brokenRoute,
      'sucios_ruta': dirtyRoute,
      'a_la_par': aLongWay,
      'comodato': loan,
      "prestamo": pLoan,
      //"test": test,
      'mal_sabor': badTaste,
      'liquido_20': transferLiquid,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'vacios': empty,
      'llenos': full,
      'rotos_cte': brokenCte,
      'sucios_cte': dirtyCte,
      'rotos_ruta': brokenRoute,
      'sucios_ruta': dirtyRoute,
      'a_la_par': aLongWay,
      'comodato': loan,
      "prestamo": pLoan,
      //"test": test,
      'mal_sabor': badTaste,
      'liquido_20': transferLiquid,
    };
  }
  CarboyModel copy() {
    return CarboyModel(
      empty: this.empty,
      full: this.full,
      brokenCte: this.brokenCte,
      dirtyCte: this.dirtyCte,
      brokenRoute: this.brokenRoute,
      dirtyRoute: this.dirtyRoute,
      aLongWay: this.aLongWay,
      loan: this.loan,
      pLoan: this.pLoan,
      //test: this.test,
      badTaste: this.badTaste,
      transferLiquid: this.transferLiquid,
    );
  }

  void incrementEmpty(int count) {
    empty += count;
  }

  void decrementFull(int count) {
    if (full >= count) {
      full -= count;
    } else {
      print('No hay suficientes carboys llenos para decrementar.');
    }
  }

  @override
  String toString() {
    return 'ProductCarboy(vacios: $empty, llenos: $full, rotos_cte: $brokenCte, sucios_cte: $dirtyCte, rotos_ruta: $brokenRoute, sucios_ruta: $dirtyRoute, a_la_par: $aLongWay, comodato: $loan, prestamo: $pLoan, mal_sabor: $badTaste, liquido_20: $transferLiquid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CarboyModel &&
        other.empty == empty &&
        other.full == full &&
        other.brokenCte == brokenCte &&
        other.dirtyCte == dirtyCte &&
        other.brokenRoute == brokenRoute &&
        other.dirtyRoute == dirtyRoute &&
        other.aLongWay == aLongWay &&
        other.loan == loan &&
        other.pLoan == pLoan &&
        //other.test == test &&
        other.badTaste == badTaste &&
        other.transferLiquid == transferLiquid;
  }

  @override
  int get hashCode {
    return empty.hashCode ^
    full.hashCode ^
    brokenCte.hashCode ^
    dirtyCte.hashCode ^
    brokenRoute.hashCode ^
    dirtyRoute.hashCode ^
    aLongWay.hashCode ^
    loan.hashCode ^
    pLoan.hashCode ^
    //test.hashCode ^
    badTaste.hashCode ^
    transferLiquid.hashCode;
  }
}
