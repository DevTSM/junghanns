class DemineralizedModel {
  int full;
  int brokenCte;
  int dirtyCte;
  int brokenRoute;
  int dirtyRoute;
  int pLoan;
  int transferLiquid;

  DemineralizedModel({
    required this.full,
    required this.brokenCte,
    required this.dirtyCte,
    required this.brokenRoute,
    required this.dirtyRoute,
    required this.pLoan,
    required this.transferLiquid,
  });

  factory DemineralizedModel.empty() {
    return DemineralizedModel(
      full: 1,
      brokenCte: 1,
      dirtyCte: 1,
      brokenRoute: 1,
      dirtyRoute: 1,
      pLoan: 1,
      transferLiquid: 1,
    );
  }

  factory DemineralizedModel.from(Map<String, dynamic> data) {
    return DemineralizedModel(
      full: int.parse((data["llenos_des"] ?? data["llenos"] ?? 0).toString()),
      brokenCte: int.parse((data["rotos_cte"] ?? data["roto_cte"] ?? 0).toString()),
      dirtyCte: int.parse((data["sucios_cte"] ?? data["sucio_cte"] ?? 0).toString()),
      brokenRoute: int.parse((data["roto_ruta_des"] ?? data["roto_ruta"] ?? 0).toString()),
      dirtyRoute: int.parse((data["sucio_ruta_des"] ?? data["sucio_ruta"] ?? 0).toString()),
      pLoan: int.parse((data["prestamo"] ?? data["prestamo"] ?? 0).toString()),
      transferLiquid: int.parse((data["liquido_desmi"]?? data["liquido_desmi"] ?? 0).toString()),
    );
  }
  Map<String, dynamic> toPostJson() {
    return {
      'llenos_des': full,
      'rotos_cte': brokenCte,
      'sucios_cte': dirtyCte,
      'sucios_ruta_des': dirtyRoute,
      'rotos_ruta_des': brokenRoute,
      'prestamo': pLoan,
      "liquido_desmi": transferLiquid,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'llenos': full,
      'rotos_cte': brokenCte,
      'sucios_cte': dirtyCte,
      'roto_ruta': brokenRoute,
      'sucio_ruta': dirtyRoute,
      "prestamo": pLoan,
      "liquido_desmi": transferLiquid,
    };
  }
  DemineralizedModel copy() {
    return DemineralizedModel(
      full: this.full,
      brokenCte: this.brokenCte,
      dirtyCte: this.dirtyCte,
      brokenRoute: this.brokenRoute,
      dirtyRoute: this.dirtyRoute,
      pLoan: this.pLoan,
      transferLiquid: this.transferLiquid,
    );
  }

  /*void incrementEmpty(int count) {
    empty += count;
  }

  void decrementFull(int count) {
    if (full >= count) {
      full -= count;
    } else {
      print('No hay suficientes carboys llenos para decrementar.');
    }
  }*/

  @override
  String toString() {
    return 'ProductDemineralizedModel(llenos: $full, rotos_cte: $brokenCte, sucios_cte: $dirtyCte, rotos_ruta: $brokenRoute, sucios_ruta: $dirtyRoute,  prestamo: $pLoan, liquido_desmi: $transferLiquid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DemineralizedModel &&
        other.full == full &&
        other.brokenCte == brokenCte &&
        other.dirtyCte == dirtyCte &&
        other.brokenRoute == brokenRoute &&
        other.dirtyRoute == dirtyRoute &&
        other.pLoan == pLoan &&
        other.transferLiquid == transferLiquid;
  }

  @override
  int get hashCode {
    return full.hashCode ^
    brokenCte.hashCode ^
    dirtyCte.hashCode ^
    brokenRoute.hashCode ^
    dirtyRoute.hashCode ^
    pLoan.hashCode ^
    transferLiquid.hashCode;
  }
}
