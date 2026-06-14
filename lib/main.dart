import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/category_provider.dart';
import 'package:sales/providers/client_provider.dart';
import 'package:sales/providers/product_provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/router/app_router.dart'; // ← importar el router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Los Providers no cambian — siguen registrados aquí.
        // Todas las rutas de go_router tienen acceso a ellos
        // porque el MultiProvider envuelve al MaterialApp.router.
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      // MaterialApp.router en lugar de MaterialApp.
      // routerConfig recibe la instancia de GoRouter definida en app_router.dart.
      // Ya no se usa home: — el router define la pantalla inicial con initialLocation.
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
