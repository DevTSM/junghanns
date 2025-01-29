class CarboyElevenModel {
  int empty;
  int full;
  int brokenCte;
  int dirtyCte;
  int brokenRoute;
  int dirtyRoute;
  int aLongWay;
  int loan;
  int pLoan;
  int badTaste;
  int transferLiquid;

  CarboyElevenModel({
    required this.empty,
    required this.full,
    required this.brokenCte,
    required this.dirtyCte,
    required this.brokenRoute,
    required this.dirtyRoute,
    required this.aLongWay,
    required this.loan,
    required this.pLoan,
    required this.badTaste,
    required this.transferLiquid,
  });

  factory CarboyElevenModel.empty() {
    return CarboyElevenModel(
      full: 1,
      empty: 1,
      brokenCte: 1,
      dirtyCte: 1,
      brokenRoute: 1,
      dirtyRoute: 1,
      aLongWay: 1,
      loan: 1,
      pLoan: 1,
      badTaste: 1,
      transferLiquid: 1,
    );
  }

  factory CarboyElevenModel.from(Map<String, dynamic> data) {
    return CarboyElevenModel(
      full: int.parse((data["llenos_11"] ?? data["llenos"] ?? 0).toString()),
      empty: int.parse((data["vacios_11"] ?? data["vacios"] ?? 0).toString()),
      brokenCte: int.parse((data["roto_cte_11"] ?? data["rotos_cte"] ?? 0).toString()),
      dirtyCte: int.parse((data["sucios_cte_11"] ?? data["sucios_cte"] ?? 0).toString()),
      brokenRoute: int.parse((data["roto_ruta_11"] ?? data["rotos_ruta"] ?? 0).toString()),
      dirtyRoute: int.parse((data["sucio_ruta_11"] ?? data["sucios_ruta"] ?? 0).toString()),
      aLongWay: int.parse((data["a_la_par_11"] ?? data["a_la_par"] ?? 0).toString()),
      loan: int.parse((data["comodato_11"] ?? data["comodato"] ?? 0).toString()),
      pLoan: int.parse((data["prestamo_11"] ?? data["prestamo"] ?? 0).toString()),
      badTaste: int.parse((data["mal_sabor_11"] ?? data["mal_sabor"] ?? 0).toString()),
      transferLiquid: int.parse((data["liquido_11"] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toPostElevenJson() {
    return {
      'llenos_11': full,
      'vacios_11': empty,
      'roto_cte_11': brokenCte,
      'sucios_cte_11': dirtyCte,
      'roto_ruta_11': brokenRoute,
      'sucio_ruta_11': dirtyRoute,
      'a_la_par_11': aLongWay,
      'comodato_11': loan,
      "prestamo_11": pLoan,
      'mal_sabor_11': badTaste,
      'liquido_11': transferLiquid,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'llenos': full,
      'vacios': empty,
      'roto_cte': brokenCte,
      'sucios_cte': dirtyCte,
      'roto_ruta': brokenRoute,
      'sucio_ruta': dirtyRoute,
      'a_la_par': aLongWay,
      'comodato': loan,
      "prestamo": pLoan,
      'mal_sabor': badTaste,
      'liquido_11': transferLiquid,
    };
  }
  CarboyElevenModel copy() {
    return CarboyElevenModel(
      empty: this.empty,
      full: this.full,
      brokenCte: this.brokenCte,
      dirtyCte: this.dirtyCte,
      brokenRoute: this.brokenRoute,
      dirtyRoute: this.dirtyRoute,
      aLongWay: this.aLongWay,
      loan: this.loan,
      pLoan: this.pLoan,
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
    return 'ProductCarboyElevenModel(vacios: $empty, llenos: $full, rotos_cte: $brokenCte, sucios_cte: $dirtyCte, rotos_ruta: $brokenRoute, sucios_ruta: $dirtyRoute, a_la_par: $aLongWay, comodato: $loan, prestamo: $pLoan, mal_sabor: $badTaste, liquido_11: $transferLiquid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CarboyElevenModel &&
        other.empty == empty &&
        other.full == full &&
        other.brokenCte == brokenCte &&
        other.dirtyCte == dirtyCte &&
        other.brokenRoute == brokenRoute &&
        other.dirtyRoute == dirtyRoute &&
        other.aLongWay == aLongWay &&
        other.loan == loan &&
        other.pLoan == pLoan &&
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
    badTaste.hashCode ^
    transferLiquid.hashCode;
  }
}
