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

  void _verDetalle(BuildContext context, dynamic s) {
    final synced = s.isSynced == 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
                radius: 40,
                backgroundColor: Colors.blue,
                child: Icon(Icons.business, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(s.nombre,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.badge, color: Colors.blue),
                title: const Text('RUC'),
                subtitle: Text(s.ruc),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text('Teléfono'),
                subtitle: Text(s.telefono),
              ),
              ListTile(
                leading: Icon(
                  synced ? Icons.cloud_done : Icons.cloud_off,
                  color: synced ? Colors.green : Colors.orange,
                ),
                title: const Text('Estado'),
                subtitle: Text(synced ? 'Sincronizado' : 'Pendiente'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupplierFormScreen(supplier: s),
                          ),
                        );
                        context.read<SupplierProvider>().loadAll();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Eliminar',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar'),
                            content: Text('¿Eliminar a ${s.nombre}?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().suppliers;

    //por si me olvido xd

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
      body: suppliers.isEmpty
          ? const Center(child: Text('No hay proveedores'))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final s = suppliers[index];
          final synced = s.isSynced == 1;
          return GestureDetector(
            onTap: () => _verDetalle(context, s),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.business,
                          size: 35, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.ruc,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: synced ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        synced ? 'Sincronizado' : 'Pendiente',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}