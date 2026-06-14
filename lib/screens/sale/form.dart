import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/client_provider.dart';
import 'package:sales/providers/product_provider.dart';
import 'package:sales/providers/sale_provider.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  Client? _selectedClient;
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  //aqui es el array donde de guarda temporalmente lo del carrito
  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    context.read<ClientProvider>().loadSynced();
    context.read<ProductProvider>().loadAll();
  }

  double get _subtotal =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  double get _igv => _subtotal * 0.18;
  double get _total => _subtotal + _igv;

  //por si las moscas

  void _addToCart() {
    if (_selectedProduct == null) return;
    final qty = int.tryParse(_quantityController.text) ?? 1;
    final existing = _cart.indexWhere((c) => c.product.id == _selectedProduct!.id);
    setState(() {
      if (existing >= 0) {
        _cart[existing].quantity += qty;
      } else {
        _cart.add(CartItem(product: _selectedProduct!, quantity: qty));
      }
    });
    _quantityController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().clients;
    final products = context.watch<ProductProvider>().products;

    // Sin Scaffold — AppShell provee el Scaffold con botón atrás.
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          DropdownButtonFormField<Client>(
            decoration: const InputDecoration(
              labelText: 'Cliente',
              border: OutlineInputBorder(),
            ),
            value: _selectedClient,
            items: clients.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            )).toList(),
            onChanged: (val) => setState(() => _selectedClient = val),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<Product>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProduct,
                  items: products.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p.name} - S/ ${p.price}',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cant.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _cart.isEmpty
                ? const Center(child: Text('No hay productos en el carrito'))
                : ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(
                      'S/ ${item.product.price} x ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            setState(() => _cart.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_cart.isNotEmpty) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('S/ ${_subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('IGV (18%):'),
                Text('S/ ${_igv.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('S/ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () async {
              if (_selectedClient == null || _cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Selecciona cliente y agrega productos')),
                );
                return;
              }
              final details = _cart
                  .map((item) => {
                'product': item.product.id,
                'quantity': item.quantity,
              })
                  .toList();
              await context.read<SaleProvider>().save(
                _selectedClient!.serverId!,
                details,
              );
              if (context.mounted) context.pop();
            },
            child: const Text('Confirmar Venta',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
