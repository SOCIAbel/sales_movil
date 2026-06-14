import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/providers/sale_provider.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  String _search = '';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadAll();
  }

  void _verDetalle(BuildContext context, Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.receipt_long, size: 35, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('Boleta de Venta #${sale.id}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(sale.clientName,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(sale.createdAt.substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 24),
              ...sale.details.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('${d.productName} x${d.quantity}')),
                    Text('S/ ${d.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text('S/ ${sale.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('IGV (18%):'),
                  Text('S/ ${sale.igv.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('S/ ${sale.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSales = context.watch<SaleProvider>().sales;

    final sales = allSales.where((sale) {
      final matchSearch = _search.isEmpty ||
          sale.clientName.toLowerCase().contains(_search.toLowerCase()) ||
          sale.id.toString().contains(_search);
      final matchDate = _filterDate == null ||
          sale.createdAt.substring(0, 10) ==
              '${_filterDate!.year}-${_filterDate!.month.toString().padLeft(2, '0')}-${_filterDate!.day.toString().padLeft(2, '0')}';
      return matchSearch && matchDate;
    }).toList();

    // Scaffold sin AppBar — AppShell provee el AppBar.
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => context.push('/sales/form'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por cliente o # venta...',
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
                const SizedBox(width: 6),
                // Filtro de fecha — movido del AppBar al body porque
                // AppShell centraliza un único AppBar sin actions por pantalla.
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.green),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    setState(() => _filterDate = picked);
                  },
                ),
                if (_filterDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _filterDate = null),
                  ),
              ],
            ),
          ),
          if (_filterDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                      'Fecha: ${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _filterDate = null),
                ),
              ),
            ),
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text('No hay ventas'))
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                final productos = sale.details.isNotEmpty
                    ? sale.details.map((d) => d.productName).join(', ')
                    : 'Sin producto';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        '#${sale.id}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    title: Text(sale.clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(productos,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(sale.createdAt.substring(0, 10),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'S/ ${sale.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _verDetalle(context, sale),
                          child: const Icon(Icons.visibility,
                              color: Colors.green, size: 22),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
