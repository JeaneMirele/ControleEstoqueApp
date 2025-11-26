import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list_item.dart';
import '../view_models/shopping_list_view_model.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingListItem item;

  const ShoppingItemTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);

    return Opacity(
      opacity: item.isChecked ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item.nome,
            style: TextStyle(
              fontSize: 16,
              decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: Text(item.categoria, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          leading: Checkbox(
            value: item.isChecked,
            onChanged: (bool? value) {
              if (value != null) {
                viewModel.toggleItemChecked(item.id!, value);
              }
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => viewModel.deleteItem(item.id!),
          ),
          onTap: () {
            viewModel.toggleItemChecked(item.id!, !item.isChecked);
          },
        ),
      ),
    );
  }
}
