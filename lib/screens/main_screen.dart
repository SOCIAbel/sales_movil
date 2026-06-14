import 'package:flutter/material.dart';

// MainScreenBody — solo el contenido de la pantalla de bienvenida.
// No necesita Scaffold, AppBar ni Drawer.
// AppShell provee todo eso automáticamente según la ruta activa.
class MainScreenBody extends StatelessWidget {
  const MainScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bienvenido al Sistema de Ventas'),
    );
  }
}
