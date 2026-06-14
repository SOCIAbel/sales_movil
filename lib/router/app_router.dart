import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sales/screens/category/detail.dart';
import 'package:sales/screens/category/form.dart';
import 'package:sales/screens/category/list.dart';
import 'package:sales/screens/client/form.dart';
import 'package:sales/screens/client/list.dart';
import 'package:sales/screens/main_screen.dart';
import 'package:sales/screens/product/detail.dart';
import 'package:sales/screens/product/form.dart';
import 'package:sales/screens/product/list.dart';
import 'package:sales/screens/sale/form.dart';
import 'package:sales/screens/sale/list.dart';
import 'package:sales/screens/supplier/form.dart';
import 'package:sales/screens/supplier/list.dart';

// Rutas raíz — muestran Drawer y hamburger en el AppBar.
// Las rutas que no estén aquí (form, detail) muestran botón atrás.
const _rootRoutes = ['/', '/categories', '/products', '/clients', '/suppliers', '/sales'];

// Mapea la ruta activa completa a su título de AppBar.
// Decisión: centralizar los títulos aquí en lugar de definirlos en cada pantalla.
String _titleFor(String location) {
  if (location == '/') return 'Sistema de Ventas';
  if (location == '/categories') return 'Lista de Categorías';
  if (location.startsWith('/categories/form')) return 'Formulario de Categoría';
  if (location.startsWith('/categories/')) return 'Detalle de Categoría';
  if (location == '/products') return 'Lista de Productos';
  if (location.startsWith('/products/form')) return 'Formulario de Producto';
  if (location.startsWith('/products/')) return 'Detalle de Producto';
  if (location == '/clients') return 'Lista de Clientes';
  if (location.startsWith('/clients/form')) return 'Formulario de Cliente';
  if (location == '/suppliers') return 'Proveedores';
  if (location.startsWith('/suppliers/form')) return 'Formulario de Proveedor';
  if (location == '/sales') return 'Ventas';
  if (location.startsWith('/sales/form')) return 'Nueva Venta';
  return 'Sales App';
}

// Instancia global del router.
// Se pasa a MaterialApp.router en main.dart como routerConfig.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        // Decisión: state.uri.toString() en lugar de state.matchedLocation.
        // state.matchedLocation devuelve la ruta del shell (/categories),
        // no la ruta hija activa (/categories/form).
        // state.uri.toString() devuelve la ruta completa activa — correcto.
        location: state.uri.toString(),
        child: child, // pantalla activa — renderiza como body del Scaffold
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreenBody(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryListScreen(),
          routes: [
            GoRoute(
              // Path relativo sin / inicial.
              // go_router lo concatena con el padre: /categories + form = /categories/form
              path: 'form',
              builder: (context, state) => CategoryFormScreen(
                // state.extra transporta objetos entre rutas.
                // null = crear nueva categoría · Category = editar existente.
                // pathParameters solo acepta strings — extra es para objetos completos.
                category: state.extra as dynamic,
              ),
            ),
            GoRoute(
              // :id es un parámetro de URL capturado en state.pathParameters['id']
              path: ':id',
              builder: (context, state) => CategoryDetailScreen(
                idCategory: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListScreen(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) => ProductFormScreen(
                product: state.extra as dynamic,
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => ProductDetailScreen(
                idProduct: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientListScreen(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) => ClientFormScreen(
                client: state.extra as dynamic,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/suppliers',
          builder: (context, state) => const SupplierListScreen(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) => SupplierFormScreen(
                supplier: state.extra as dynamic,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) => const SaleListScreen(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) => const SaleFormScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─── AppShell — único Scaffold de toda la app ────────────────────────────────
//
// Decisión arquitectónica: un solo Scaffold centralizado en lugar de uno
// por pantalla. Ventajas:
//   - AppBar y Drawer definidos una sola vez
//   - Agregar un módulo = una línea en el Drawer, una ruta en appRouter
//   - En la próxima sesión: JWT logout y nombre de usuario se agregan aquí
//
// StatelessWidget: AppShell no gestiona estado propio.
// El estado sigue viviendo en los Providers registrados en main.dart.
class AppShell extends StatelessWidget {
  final String location; // ruta activa completa, ej: /categories/form
  final Widget child;    // pantalla activa — renderiza como body

  const AppShell({super.key, required this.location, required this.child});

  // true  → ruta raíz → muestra Drawer + hamburger
  // false → ruta hija → muestra botón atrás, sin Drawer
  bool get _isRoot => _rootRoutes.contains(location);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(location)),
        backgroundColor: Colors.orange,
        // Ruta raíz: leading null → Flutter pone el hamburger automáticamente.
        // Ruta hija: botón atrás manual con context.pop().
        leading: _isRoot
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        automaticallyImplyLeading: _isRoot,
      ),
      // Drawer solo en rutas raíz — en formularios y detalles no aparece
      drawer: _isRoot ? _buildDrawer(context) : null,
      body: child,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Text(
              'Sales App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _drawerItem(context, icon: Icons.home,         label: 'Inicio',     route: '/'),
          _drawerItem(context, icon: Icons.category,     label: 'Categorías', route: '/categories'),
          _drawerItem(context, icon: Icons.inventory_2,  label: 'Productos',  route: '/products'),
          _drawerItem(context, icon: Icons.people,       label: 'Clientes',   route: '/clients'),
          _drawerItem(context, icon: Icons.business,     label: 'Proveedores', route: '/suppliers'),
          _drawerItem(context, icon: Icons.point_of_sale, label: 'Ventas',    route: '/sales'),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = location == route;

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.orange : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.orange : null,
        ),
      ),
      selected: isActive,
      onTap: () {
        if (!isActive) {
          // Decisión: el Drawer es una ruta de Navigator interno del Scaffold.
          // context.go() opera sobre go_router — un nivel superior.
          // Se cierra el Drawer con Navigator.pop ANTES de navegar con context.go.
          // Este orden garantiza que el árbol del Drawer se destruya limpiamente
          // antes de que go_router cambie la ruta activa.
          Navigator.of(context).pop(); // cierra el Drawer
          context.go(route);           // cambia la ruta en go_router
        }
      },
    );
  }
}
