import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/supplier.dart';
import 'package:sales/providers/supplier_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier; // null = crear · Supplier = editar

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _nombre = '';
  String _ruc = '';
  String _telefono = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final provider = context.read<SupplierProvider>();
      final supplier = Supplier(
        id: widget.supplier?.id ?? 0,
        nombre: _nombre,
        ruc: _ruc,
        telefono: _telefono,
      );
      if (widget.supplier == null) {
        await provider.saveLocal(supplier);
      } else {
        await provider.editLocal(widget.supplier!.localId!, supplier);
      }
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold — AppShell provee el Scaffold con botón atrás.
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.supplier?.nombre ?? '',
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 2) return 'Mínimo 2 caracteres';
                return null;
              },
              onSaved: (value) => _nombre = value!.trim(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.supplier?.ruc ?? '',
              decoration: const InputDecoration(
                labelText: 'RUC',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El RUC es requerido';
                }
                if (value.trim().length != 11) {
                  return 'El RUC debe tener 11 dígitos';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Solo se permiten números';
                }
                return null;
              },
              onSaved: (value) => _ruc = value!.trim(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.supplier?.telefono ?? '',
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es requerido';
                }
                if (value.trim().length < 6) {
                  return 'Mínimo 6 dígitos';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Solo se permiten números';
                }
                return null;
              },
              onSaved: (value) => _telefono = value!.trim(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.supplier == null ? 'Guardar' : 'Editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
