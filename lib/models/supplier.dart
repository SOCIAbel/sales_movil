class Supplier {
  final int id;
  final String nombre;
  final String ruc;
  final String telefono;
  final int isSynced;
  final int? serverId;
  final int? localId;

  Supplier({
    required this.id,
    required this.nombre,
    required this.ruc,
    required this.telefono,
    this.isSynced = 1,
    this.serverId,
    this.localId,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      nombre: json['nombre'].toString(),
      ruc: json['ruc'].toString(),
      telefono: json['telefono'].toString(),
    );
  }

  factory Supplier.fromDb(Map<String, dynamic> db) {
    return Supplier(
      id: db['server_id'] ?? 0,
      localId: db['id'],
      nombre: db['nombre'].toString(),
      ruc: db['ruc'].toString(),
      telefono: db['telefono'].toString(),
      isSynced: db['is_synced'],
      serverId: db['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
    };
  }

  Map<String, dynamic> toDb() {
    return {
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
      'is_synced': 0,
      'server_id': null,
    };
  }
}