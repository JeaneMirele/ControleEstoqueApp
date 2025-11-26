import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/shopping_list_view_model.dart';
import '../components/shopping_item_tile.dart';
import '../../models/shopping_list_item.dart';
import '../components/app_drawer.dart';
import '../components/add_shopping_item_dialog.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
      ),
      drawer: const AppDrawer(currentPage: 'shopping_list'),
      body: StreamBuilder<List<ShoppingListItem>>(
        stream: viewModel.shoppingList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Sua lista de compras está vazia!\nProdutos com estoque baixo aparecerão aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ShoppingItemTile(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddShoppingItemDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
