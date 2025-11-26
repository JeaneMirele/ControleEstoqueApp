import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/shopping_list_view_model.dart';
import '../components/shopping_item_tile.dart';
import '../../models/shopping_list_item.dart';
import '../components/app_drawer.dart';
import '../components/add_shopping_item_dialog.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({Key? key}) : super(key: key);

  void _mostrarDialogoDelecao(BuildContext context, ShoppingListItem item) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja remover "${item.nome}" da lista?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
              onPressed: () {
                viewModel.deleteItem(item.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${item.nome}" foi removido.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFF13EC5B);
    final Color backgroundColor = isDarkMode ? const Color(0xFF102216) : const Color(0xFFF6F8F6);
    final Color cardColor = isDarkMode ? const Color(0x8018181B) : Colors.white; // zinc-900/50
    final Color searchBarColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7); // zinc-800 / zinc-200
    final Color dividerColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7); // zinc-800 / zinc-200

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AppDrawer(currentPage: 'shopping_list'),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: backgroundColor.withOpacity(0.85),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: const Text('Minha Lista de Compras', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // TODO: Implementar filtro
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                onChanged: (value) {
                  viewModel.setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar na lista...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search),
                  ),
                  prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
                  filled: true,
                  fillColor: searchBarColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<ShoppingListItem>>(
            stream: viewModel.shoppingList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_checkout, size: 60, color: Color(0xFF13EC5B)),
                          SizedBox(height: 16),
                          Text(
                            'Sua despensa está cheia!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nenhum item em falta no momento. Adicione um item manualmente se precisar.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final items = snapshot.data!;
              final automaticItems = items.where((i) => i.isAutomatic && !i.isChecked).toList();
              final manualItems = items.where((i) => !i.isAutomatic && !i.isChecked).toList();
              final purchasedItems = items.where((i) => i.isChecked).toList();

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 96), // Espaço para o FAB
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (automaticItems.isNotEmpty)
                      _buildSection(context, 'Gerado Automaticamente', automaticItems, cardColor, dividerColor),
                    if (manualItems.isNotEmpty)
                      _buildSection(context, 'Adicionado Manualmente', manualItems, cardColor, dividerColor),
                    if (purchasedItems.isNotEmpty)
                      _buildSection(context, 'Comprados', purchasedItems, cardColor, dividerColor),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddShoppingItemDialog(),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, size: 28, color: Colors.black87),
        shape: const CircleBorder(),
        heroTag: 'add_shopping_item_fab',
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<ShoppingListItem> items, Color cardColor, Color dividerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDarkMode(context)
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ShoppingItemTile(
                    item: item,
                    onLongPress: () => _mostrarDialogoDelecao(context, item),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                  indent: 16,
                  endIndent: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
