import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/produto.dart';

class EstoqueItemCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onAumentar;
  final VoidCallback? onDiminuir;
  final VoidCallback? onLongPress;

  const EstoqueItemCard({
    Key? key,
    required this.produto,
    this.onAumentar,
    this.onDiminuir,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;



    final Color accentColor = _getAccentColor(produto.validade);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [

              Container(
                width: 5,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),


              Icon(produto.getIcone(), size: 40, color: isDarkMode ? Colors.white70 : Colors.black54),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),


                    Text(
                      'Validade: ${DateFormat('dd/MM/yyyy').format(produto.validade)}',
                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    ),

                    const SizedBox(height: 2),
                    Text(
                      'Categoria: ${produto.categoria}',
                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),


              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      onPressed: onAumentar,
                      color: isDarkMode ? Colors.greenAccent : Colors.green,
                    ),
                  ),
                  Text(
                    produto.quantidade.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                      onPressed: onDiminuir,
                      color: isDarkMode ? Colors.redAccent : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Color _getAccentColor(DateTime dataValidade) {
    final hoje = DateTime.now();


    final dataValidadeSemHora = DateTime(dataValidade.year, dataValidade.month, dataValidade.day);
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    final diff = dataValidadeSemHora.difference(hojeSemHora).inDays;

    if (diff < 0) return Colors.red;
    if (diff <= 2) return Colors.orange;
    return Colors.green;
  }
}