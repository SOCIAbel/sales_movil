import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/screens/supplier/form.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().suppliers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await context.read<SupplierProvider>().sincronizar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronización completada')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
          );
          context.read<SupplierProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final s = suppliers[index];
          final synced = s.isSynced == 1;
          return ListTile(
            title: Text(s.nombre),
            subtitle: Text('RUC: ${s.ruc} | Tel: ${s.telefono}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: synced ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    synced ? 'Sincronizado' : 'Pendiente',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupplierFormScreen(supplier: s),
                      ),
                    );
                    context.read<SupplierProvider>().loadAll();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar'),
                        content: Text('¿Eliminar a ${s.nombre}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await context.read<SupplierProvider>().delete(
                        s.localId!,
                        s.serverId ?? 0,
                        s.isSynced == 1,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}