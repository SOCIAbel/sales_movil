import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/client_provider.dart';
import 'package:sales/providers/product_provider.dart';
import 'package:sales/providers/sale_provider.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  Client? _selectedClient;
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    context.read<ClientProvider>().loadAll();
    context.read<ProductProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().clients;
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              value: _selectedClient,
              items: clients.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedClient = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Product>(
              decoration: const InputDecoration(
                labelText: 'Producto',
                border: OutlineInputBorder(),
              ),
              value: _selectedProduct,
              items: products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} - S/ ${p.price}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedProduct = val),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_selectedClient == null || _selectedProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona cliente y producto')),
                  );
                  return;
                }
                await context.read<SaleProvider>().save(
                  _selectedClient!.id,
                  _selectedProduct!.id,
                  int.parse(_quantityController.text),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar Venta'),
            ),
          ],
        ),
      ),
    );
  }
}