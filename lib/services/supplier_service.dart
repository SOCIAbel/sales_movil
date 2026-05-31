import 'package:sales/config/app_config.dart';
import 'package:sales/models/supplier.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SupplierService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Supplier>> all() async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((j) => Supplier.fromJson(j)).toList();
    } else {
      throw Exception('Error al cargar proveedores');
    }
  }

  Future<Supplier> save(Supplier supplier) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/');
    var response = await http.post(
      url,
      body: convert.jsonEncode(supplier.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      return Supplier.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Error al guardar proveedor');
    }
  }

  Future<void> edit(int id, Supplier supplier) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/$id/');
    var response = await http.put(
      url,
      body: convert.jsonEncode(supplier.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error al editar proveedor');
    }
  }

  Future<void> delete(int id) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/$id/');
    var response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proveedor');
    }
  }
}