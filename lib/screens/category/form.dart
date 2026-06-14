import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/category.dart';
import '../../providers/category_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // null = crear · Category = editar

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  // GlobalKey: vive en el estado del StatefulWidget — nunca en build().
  // Si viviera en build(), se recrearía en cada rebuild y perdería la referencia al Form.
  final _formKey = GlobalKey<FormState>();

  // Variables que recibirán los valores cuando se ejecute _formKey.currentState!.save()
  String _name = '';
  String _description = '';

  // Controla el estado del botón — lo deshabilita durante la operación async
  bool _isLoading = false;

  Future<void> _submit() async {
    // PASO 1: validate() ejecuta el validator de cada TextFormField.
    // Si alguno falla → mensaje bajo el campo → retorna false → no continúa.
    if (!_formKey.currentState!.validate()) return;

    // PASO 2: save() ejecuta el onSaved de cada TextFormField.
    // Copia los valores a _name y _description.
    // Solo se ejecuta porque validate() retornó true.
    _formKey.currentState!.save();

    // PASO 3: construir el objeto y llamar al Provider.
    // El formulario no conoce al Provider — solo extrae valores.
    setState(() => _isLoading = true);
    try {
      final provider = context.read<CategoryProvider>();
      if (widget.category == null) {
        // Crear — id 0, el backend asigna el id real
        await provider.save(Category(0, _name, _description));
      } else {
        // Editar — mantener el id existente
        await provider.edit(
          widget.category!.id,
          Category(widget.category!.id, _name, _description),
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
    // Sin Scaffold — AppShell provee el Scaffold con botón atrás.
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey, // conecta el Form con la GlobalKey
        // onUserInteraction: valida cuando el usuario abandona el campo.
        // No espera a que presione el botón Guardar.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              // initialValue reemplaza al TextEditingController.
              // Si estamos editando, muestra el valor actual.
              // Si estamos creando, muestra vacío.
              initialValue: widget.category?.name ?? '',
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                // null → válido · String → mensaje de error bajo el campo
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
              // onSaved se ejecuta cuando se llama _formKey.currentState!.save()
              onSaved: (value) => _name = value!.trim(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.category?.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
              onSaved: (value) => _description = value!.trim(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // null deshabilita el botón visualmente durante la carga
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.category == null ? 'Crear' : 'Editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
