import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_estoque_app/ui/views/shopping_list_page.dart';
import 'package:controle_estoque_app/ui/views/expiration_alerts_page.dart';
import 'package:controle_estoque_app/ui/views/family_settings_page.dart';
import 'package:controle_estoque_app/ui/view_models/auth_view_model.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column( 
        children: [
          Expanded(
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
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
                      Navigator.push(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExpirationAlertsPage()),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Minha Família'),
                  selected: currentPage == 'FamilySettings',
                  selectedTileColor: const Color(0xFF13EC5B).withOpacity(0.1),
                  selectedColor: const Color(0xFF13EC5B),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentPage != 'FamilySettings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FamilySettingsPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {

              final authViewModel = context.read<AuthViewModel>();
              Navigator.pop(context); 
              authViewModel.sair();
            },
          ),
          const SizedBox(height: 20), 
        ],
      ),
    );
  }
}
