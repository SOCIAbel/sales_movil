import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/screens/sale/form.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SaleProvider>().sales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SaleFormScreen()),
          );
          context.read<SaleProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          final producto = sale.details.isNotEmpty
              ? sale.details.first.productName
              : 'Sin producto';
          return ListTile(
            title: Text('Venta #${sale.id} — ${sale.clientName}'),
            subtitle: Text(
              'Producto: $producto\nFecha: ${sale.createdAt.substring(0, 10)}\nTotal: S/ ${sale.total.toStringAsFixed(2)}',
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}