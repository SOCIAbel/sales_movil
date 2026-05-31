import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/supplier.dart';
import 'package:sales/providers/supplier_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;
  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final controllerNombre = TextEditingController();
  final controllerRuc = TextEditingController();
  final controllerTelefono = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      controllerNombre.text = widget.supplier!.nombre;
      controllerRuc.text = widget.supplier!.ruc;
      controllerTelefono.text = widget.supplier!.telefono;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: controllerNombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerRuc,
              decoration: const InputDecoration(
                labelText: 'RUC',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerTelefono,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final supplier = Supplier(
                  id: widget.supplier?.id ?? 0,
                  nombre: controllerNombre.text,
                  ruc: controllerRuc.text,
                  telefono: controllerTelefono.text,
                );
                if (widget.supplier == null) {
                  await context.read<SupplierProvider>().saveLocal(supplier);
                } else {
                  await context.read<SupplierProvider>().editLocal(
                    widget.supplier!.localId!,
                    supplier,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(widget.supplier == null ? 'Guardar' : 'Editar'),
            ),
          ],
        ),
      ),
    );
  }
}