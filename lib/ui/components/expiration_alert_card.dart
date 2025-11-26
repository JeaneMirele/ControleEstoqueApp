import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produto.dart';
import '../view_models/expiration_alerts_view_model.dart';

class ExpirationAlertCard extends StatelessWidget {
  final Produto produto;

  const ExpirationAlertCard({Key? key, required this.produto}) : super(key: key);

  // Função para obter um ícone com base na categoria
  IconData _getIconForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'laticínios':
        return Icons.icecream;
      case 'grãos':
        return Icons.grain;
      case 'limpeza':
        return Icons.cleaning_services;
      case 'bebidas':
        return Icons.local_drink;
      case 'carnes':
        return Icons.kebab_dining;
      case 'frutas':
        return Icons.apple;
      case 'higiene':
        return Icons.soap;
      default:
        return Icons.inventory_2; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpirationAlertsViewModel>();
    final status = viewModel.getAlertStatus(produto);
    final statusColor = status['color'] as Color;
    final statusText = status['text'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconForCategory(produto.categoria), color: statusColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantidade: ${produto.quantidade}',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: statusColor.withOpacity(0.15),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
