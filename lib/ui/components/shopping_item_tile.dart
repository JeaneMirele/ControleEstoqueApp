import 'package:flutter/material.dart';
import '../../models/produto.dart';

class ShoppingItemTile extends StatelessWidget {
  final Produto produto;
  final bool comprado;
  final ValueChanged<bool?> onChanged;

  const ShoppingItemTile({
    super.key,
    required this.produto,
    required this.comprado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Opacity(
      opacity: comprado ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!comprado),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: comprado,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF13EC5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: theme.unselectedWidgetColor, width: 2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nomeQuantidade,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: comprado ? TextDecoration.lineThrough : TextDecoration.none,
                          color: comprado ? theme.disabledColor : textColor,
                        ),
                      ),
                      Text(
                        produto.categoria,
                        style: TextStyle(
                          fontSize: 12, 
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!comprado && produto.prioridade)
                  const Icon(Icons.priority_high, color: Colors.orange, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
