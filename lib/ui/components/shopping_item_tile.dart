import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list_item.dart';
import '../view_models/shopping_list_view_model.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback? onLongPress;

  const ShoppingItemTile({
    Key? key,
    required this.item,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);
    final Color primaryColor = const Color(0xFF13EC5B);
    final Color checkedColor = primaryColor;
    final Color uncheckedBorderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3F3F46) // zinc-600
        : const Color(0xFFD4D4D8); // zinc-300

    return InkWell(
      onTap: () => viewModel.toggleItemChecked(item.id!, !item.isChecked),
      onLongPress: onLongPress,
      child: Opacity(
        opacity: item.isChecked ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: item.isChecked,
                  onChanged: (bool? value) {
                    if (value != null) {
                      viewModel.toggleItemChecked(item.id!, value);
                    }
                  },
                  activeColor: checkedColor,
                  checkColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF102216) // background-dark
                      : Colors.white, // background-light
                  side: BorderSide(width: 2, color: uncheckedBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.nome} - ${item.quantidade}',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        color: item.isChecked
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.categoria,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.prioridade && !item.isChecked)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.priority_high,
                    color: Colors.orange[500],
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
