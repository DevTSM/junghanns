class ProductCatalogModel {
  final String description;
  final List<int> products;
  int count;
  String? label;
  String img;


  ProductCatalogModel({required this.description, required this.products, required this.count, required this.label, required this.img});

  factory ProductCatalogModel.empty(){
    return ProductCatalogModel(description: '', products: [], count: 1, label: '', img: '');
  }
  // Método para crear una instancia de Producto desde un JSON
  factory ProductCatalogModel.fromJson(Map<String, dynamic> json) {
    return ProductCatalogModel(
      description: json['descripcion'],
      products: List<int>.from(json['productos']['id']),
      count: int.parse(json['cantidad'] ?? '1'),
      label: '',
      img: json["url"] ?? "https://thumbs.dreamstime.com/b/botellas-de-agua-12522340.jpg",
    );
  }

  factory ProductCatalogModel.fromThis(ProductCatalogModel current){
    return ProductCatalogModel(
      description: current.description,
      products: current.products,
      count: 1,
      label: '',
      img: current.img,
    );
  }

  // Método para convertir una instancia de Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'descripcion': description,
      'productos': {
        'id': products,
      },
    };
  }

  Map<String, dynamic> toProduct() {
    return {
      'id_producto': products,
      'cantidad': count,
    };
  }

  @override
  String toString() {
    return 'Producto(descripcion: $description, productos: $products)';
  }
}
