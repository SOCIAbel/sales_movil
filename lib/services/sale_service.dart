import 'package:sales/config/app_config.dart';
import 'package:sales/models/sale.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Sale>> all() async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((j) => Sale.fromJson(j)).toList();
    } else {
      throw Exception('Error al cargar ventas');
    }
  }

  Future<void> save(int clientId, List<Map<String, dynamic>> details) async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var body = convert.jsonEncode({
      'client': clientId,
      'details': details,
    });
    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      throw Exception('Error al guardar venta');
    }
  }
}