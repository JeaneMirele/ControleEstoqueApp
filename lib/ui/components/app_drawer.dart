import 'package:flutter/material.dart';
import 'package:controle_estoque_app/ui/views/estoque_page.dart';
import 'package:controle_estoque_app/ui/views/shopping_list_page.dart';
import 'package:controle_estoque_app/ui/views/expiration_alerts_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF13EC5B),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Estoque'),
            selected: currentPage == 'Estoque',
            selectedTileColor: const Color(0xFF13EC5B).withOpacity(0.1),
            selectedColor: const Color(0xFF13EC5B),
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'Estoque') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EstoquePage()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Minha Lista de Compras'),
            selected: currentPage == 'ShoppingList',
            selectedTileColor: const Color(0xFF13EC5B).withOpacity(0.1),
            selectedColor: const Color(0xFF13EC5B),
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'ShoppingList') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingListPage()),
                );
              }
            },
          ),
           ListTile(
            leading: const Icon(Icons.notification_important),
            title: const Text('Alertas de Vencimento'),
            selected: currentPage == 'ExpirationAlerts',
            selectedTileColor: const Color(0xFF13EC5B).withOpacity(0.1),
            selectedColor: const Color(0xFF13EC5B),
            onTap: () {
              Navigator.pop(context);
              if (currentPage != 'ExpirationAlerts') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpirationAlertsPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
