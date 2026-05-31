class SaleDetail {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  SaleDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      productId: json['product']['id'],
      productName: json['product']['name'].toString(),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

class Sale {
  final int id;
  final int clientId;
  final String clientName;
  final String createdAt;
  final double subtotal;
  final double igv;
  final double total;
  final List<SaleDetail> details;

  Sale({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.createdAt,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.details,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      clientId: json['client']['id'],
      clientName: json['client']['name'].toString(),
      createdAt: json['created_at'].toString(),
      subtotal: double.parse(json['subtotal'].toString()),
      igv: double.parse(json['igv'].toString()),
      total: double.parse(json['total'].toString()),
      details: (json['details'] as List)
          .map((d) => SaleDetail.fromJson(d))
          .toList(),
    );
  }
}