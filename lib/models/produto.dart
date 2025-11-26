import 'package:flutter/material.dart';

class Produto {
  String? id;
  final String nome;
  final String validade;
  final int quantidade; // Alterado de String para int
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

  // Método auxiliar para conversão segura
  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  factory Produto.fromMap(String docId, Map<String, dynamic> map) {
    return Produto(
      id: docId,
      nome: map['nome'] ?? '',
      validade: map['validade'] ?? '',
      quantidade: _parseInt(map['quantidade']), // Conversão segura
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
      'quantidade': quantidade, // Agora é um int
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

  // Atualizado para usar a quantidade como número
  String get nomeQuantidade => '$nome - ${quantidade.toString()}';

  Produto copyWith({
    String? id,
    String? nome,
    String? validade,
    int? quantidade,
    String? categoria,
    int? iconeCodePoint,
    bool? comprado,
    bool? prioridade,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      validade: validade ?? this.validade,
      quantidade: quantidade ?? this.quantidade,
      categoria: categoria ?? this.categoria,
      iconeCodePoint: iconeCodePoint ?? this.iconeCodePoint,
      comprado: comprado ?? this.comprado,
      prioridade: prioridade ?? this.prioridade,
    );
  }
}
