import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String? id;
  final String nome;
  final String quantidade;
  final String categoria;
  bool isChecked;

  ShoppingListItem({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.categoria,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'categoria': categoria,
      'isChecked': isChecked,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map, String documentId) {
    return ShoppingListItem(
      id: documentId,
      nome: map['nome'] ?? '',
      quantidade: map['quantidade']?.toString() ?? '1',
      categoria: map['categoria'] ?? 'Outros',
      isChecked: map['isChecked'] ?? false,
    );
  }
}
