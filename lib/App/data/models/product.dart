class Product {
  final int id;
  final String name;
  final double rate;

  Product({
    required this.id,
    required this.name,
    required this.rate,
  });

  // Convert a Product object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'p_id': id,
      'name': name,
      'rate': rate,
    };
  }

  // Extract a Product object from a Map object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['p_id'],
      name: map['name'],
      rate: map['rate'],
    );
  }
}
