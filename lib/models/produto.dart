import 'package:flutter/material.dart';

class Produto {
  String? id;
  final String nome;
  final String validade;
  final String quantidade;
  final String categoria;
  final int? iconeCodePoint;
  bool comprado;
  bool prioridade;

  Produto({
    this.id,
    required this.nome,
    required this.validade,
    required this.quantidade,
    required this.categoria,
    this.iconeCodePoint,
    this.comprado = false,
    this.prioridade = false,
  });

 factory Produto.fromMap(String docId, Map<String, dynamic> map) {
    return Produto(
      id: docId,
      nome: map['nome'] ?? '',
      validade: map['validade'] ?? '',
      quantidade: map['quantidade']?.toString() ?? '0',
      categoria: map['categoria'] ?? 'Geral',
      iconeCodePoint: map['iconeCodePoint'],
      comprado: map['comprado'] ?? false,
      prioridade: map['prioridade'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'validade': validade,
      'quantidade': quantidade,
      'categoria': categoria,
      'iconeCodePoint': iconeCodePoint,
      'comprado': comprado,
      'prioridade': prioridade,
    };
  }

  IconData getIcone() {
    if (iconeCodePoint == null) return Icons.list;
    return IconData(iconeCodePoint!, fontFamily: 'MaterialIcons');
  }

  String get nomeQuantidade => '$nome - $quantidade';
}
