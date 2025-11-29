import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Produto {
  String? id;
  final String? userId;
  final String nome;
  final DateTime validade;
  final int quantidade;
  final String categoria;
  final int? iconeCodePoint;
  bool comprado;
  bool prioridade;

  Produto({
    this.id,
    this.userId,
    required this.nome,
    required this.validade,
    required this.quantidade,
    required this.categoria,
    this.iconeCodePoint,
    this.comprado = false,
    this.prioridade = false,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Produto.fromMap(String docId, Map<String, dynamic> map) {
    return Produto(
      id: docId,
      userId: map['userId'],
      nome: map['nome'] ?? '',
      validade: _parseDate(map['validade']),
      quantidade: _parseInt(map['quantidade']),
      categoria: map['categoria'] ?? 'Geral',
      iconeCodePoint: map['iconeCodePoint'],
      comprado: map['comprado'] ?? false,
      prioridade: map['prioridade'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'validade': Timestamp.fromDate(validade),
      'quantidade': quantidade,
      'categoria': categoria,
      'iconeCodePoint': iconeCodePoint,
      'comprado': comprado,
      'prioridade': prioridade,
    };
  }

  String get validadeFormatada {
    return DateFormat('dd/MM/yyyy').format(validade);
  }

  IconData getIcone() {
    if (iconeCodePoint == null) return Icons.list;
    return IconData(iconeCodePoint!, fontFamily: 'MaterialIcons');
  }

  Produto copyWith({
    String? id,
    String? userId,
    String? nome,
    DateTime? validade,
    int? quantidade,
    String? categoria,
    int? iconeCodePoint,
    bool? comprado,
    bool? prioridade,
  }) {
    return Produto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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