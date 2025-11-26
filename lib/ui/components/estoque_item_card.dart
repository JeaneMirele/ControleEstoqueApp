import 'package:flutter/material.dart';
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
    final Color shadowColor = isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2);
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
              // Indicador de validade
              Container(
                width: 5,
                height: 80, // Altura para alinhar com o conteúdo
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              // Ícone do produto
              Icon(produto.getIcone(), size: 40, color: isDarkMode ? Colors.white70 : Colors.black54),
              const SizedBox(width: 12),
              // Informações do produto
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
                      'Validade: ${produto.validade}',
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
              // Controles de quantidade
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

  Color _getAccentColor(String validadeStr) {
    // Lógica para determinar a cor com base na validade
    // (pode ser aprimorada)
    if (validadeStr.isEmpty) return Colors.grey;
    try {
      final parts = validadeStr.split('/');
      final dataValidade = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final hoje = DateTime.now();
      final diff = dataValidade.difference(hoje).inDays;

      if (diff < 0) return Colors.red; // Vencido
      if (diff <= 7) return Colors.orange; // Vence em 7 dias
      return Colors.green; // Longe de vencer
    } catch (e) {
      return Colors.grey;
    }
  }
}
