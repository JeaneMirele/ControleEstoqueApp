import 'package:flutter/material.dart';

class Produto {
  String? id;
  final String nome;
  final String validade;
  final String quantidade;
  final String categoria;
  final int? iconeCodePoint;

  Produto({
    this.id,
    required this.nome,
    required this.validade,
    required this.quantidade,
    required this.categoria,
    this.iconeCodePoint,
  });

  factory Produto.fromMap(String docId, Map<String, dynamic> map) {
    return Produto(
      id: docId,
      nome: map['nome'] ?? '',
      validade: map['validade'] ?? '',
      quantidade: map['quantidade'] ?? '0',
      categoria: map['categoria'] ?? 'Geral',
      iconeCodePoint: map['iconeCodePoint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'validade': validade,
      'quantidade': quantidade,
      'categoria': categoria,
      'iconeCodePoint': iconeCodePoint,
    };
  }

  IconData getIcone() {
    if (iconeCodePoint == null) return Icons.list;
    return IconData(iconeCodePoint!, fontFamily: 'MaterialIcons');
  }
}