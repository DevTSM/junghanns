class CarboyModel {
  int empty;
  int full;
  int brokenCte;
  int dirtyCte;
  int brokenRoute;
  int dirtyRoute;
  int aLongWay;

  CarboyModel({
    required this.empty,
    required this.full,
    required this.brokenCte,
    required this.dirtyCte,
    required this.brokenRoute,
    required this.dirtyRoute,
    required this.aLongWay,
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
    );
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
    };
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
    return 'ProductCarboy(vacios: $empty, llenos: $full, rotos_cte: $brokenCte, sucios_cte: $dirtyCte, rotos_ruta: $brokenRoute, sucios_ruta: $dirtyRoute, a_la_par: $aLongWay,)';
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
        other.aLongWay == aLongWay;
  }

  @override
  int get hashCode {
    return empty.hashCode ^
    full.hashCode ^
    brokenCte.hashCode ^
    dirtyCte.hashCode ^
    brokenRoute.hashCode ^
    dirtyRoute.hashCode ^
    aLongWay.hashCode;
  }
}
