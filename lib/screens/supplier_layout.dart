import 'package:flutter/material.dart';

class SupplierLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const SupplierLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Supplier Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menu Options',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: currentRoute == '/dashboard',
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/dashboard') {
                  Navigator.pushNamed(context, '/dashboard');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Funding'),
              selected: currentRoute == '/funding',
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/funding') {
                  Navigator.pushNamed(context, '/funding');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Supplier Map'),
              selected: currentRoute == '/supplier',
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/supplier') {
                  Navigator.pushNamed(context, '/supplier');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Provide Assistance'),
              selected: currentRoute == '/provide_assistance',
              selectedTileColor: Colors.green.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/provide_assistance') {
                  Navigator.pushNamed(context, '/provide_assistance');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Back to Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
} 