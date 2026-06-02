import 'package:flutter/material.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  List<Sale> get sales => _sales;

  final SaleService _service = SaleService();

  Future<void> loadAll() async {
    _sales = await _service.all();
    notifyListeners();
  }

  Future<void> save(int clientId, List<Map<String, dynamic>> details) async {
    await _service.save(clientId, details);
    await loadAll();
  }
}