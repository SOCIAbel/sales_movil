import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/providers/client_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client; // null = crear · Client = editar

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _name = '';
  String _documentNumber = '';

  Future<void> _submit() async {
    // validate() — ejecuta todos los validators
    if (!_formKey.currentState!.validate()) return;

    // save() — ejecuta todos los onSaved, copia valores a _name y _documentNumber
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final provider = context.read<ClientProvider>();
      if (widget.client == null) {
        // Crear — id 0, isSynced false, serverId null
        await provider.save(Client(0, _name, _documentNumber, false, null));
      } else {
        // Editar — mantener id y serverId, marcar como no sincronizado
        await provider.edit(
          widget.client!.id,
          Client(
            widget.client!.id,
            _name,
            _documentNumber,
            false, // marcamos como pendiente de sincronización
            widget.client!.serverId,
          ),
        );
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
    final isEditing = widget.client != null;

    // Sin Scaffold — AppShell provee el Scaffold con botón atrás
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.client?.name ?? '',
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
              onSaved: (value) => _name = value!.trim(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.client?.documentNumber ?? '',
              decoration: const InputDecoration(
                labelText: 'Número de documento',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El número de documento es requerido';
                }
                if (value.trim().length < 8) {
                  return 'Debe tener al menos 8 dígitos';
                }
                // int.tryParse retorna null si el texto contiene letras
                if (int.tryParse(value.trim()) == null) {
                  return 'Solo se permiten números';
                }
                return null;
              },
              onSaved: (value) => _documentNumber = value!.trim(),
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
                    : Text(isEditing ? 'Editar' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
