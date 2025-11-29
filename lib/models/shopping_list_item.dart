import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String? id;
  final String nome;
  final String quantidade;
  final String categoria;
  final bool isAutomatic;
  bool isChecked;
  final bool prioridade;


  final String? userId;
  final DateTime? criadoEm;

  ShoppingListItem({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.categoria,
    required this.isAutomatic,
    this.isChecked = false,
    this.prioridade = false,
    this.userId,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'categoria': categoria,
      'isChecked': isChecked,
      'isAutomatic': isAutomatic,
      'prioridade': prioridade,
      'userId': userId,
      'criadoEm': criadoEm ?? FieldValue.serverTimestamp(),
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map, String documentId) {
    return ShoppingListItem(
      id: documentId,
      nome: map['nome'] ?? '',
      quantidade: map['quantidade']?.toString() ?? '1',
      categoria: map['categoria'] ?? 'Outros',
      isChecked: map['isChecked'] ?? false,
      isAutomatic: map['isAutomatic'] ?? false,
      prioridade: map['prioridade'] ?? false,
      userId: map['userId'],
      criadoEm: map['criadoEm'] != null
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,
    );
  }
}