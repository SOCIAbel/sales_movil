import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/supplier.dart';
import 'package:sales/services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  final SupplierService _service = SupplierService();
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> loadAll() async {
    final rows = await _db.queryAllSuppliers();
    _suppliers = rows.map((r) => Supplier.fromDb(r)).toList();
    notifyListeners();
  }

  Future<void> saveLocal(Supplier supplier) async {
    await _db.insertSupplier(supplier.toDb());
    await loadAll();
  }

  Future<void> editLocal(int localId, Supplier supplier) async {
    await _db.updateSupplier(localId, supplier.toDb());
    await loadAll();
  }

  Future<void> edit(int id, Supplier supplier) async {
    await _service.edit(id, supplier);
    await loadAll();
  }

  Future<void> delete(int localId, int serverId, bool synced) async {
    if (synced && serverId != 0) {
      try {
        await _service.delete(serverId);
      } catch (_) {}
    }
    await _db.deleteSupplier(localId);
    await loadAll();
  }

  Future<void> sincronizar() async {
    final pendientes = await _db.queryPendingSuppliers();
    for (var row in pendientes) {
      final supplier = Supplier.fromDb(row);
      try {
        final saved = await _service.save(supplier);
        await _db.updateSupplierSynced(row['id'], saved.id);
      } catch (_) {}
    }
    await loadAll();
  }
}