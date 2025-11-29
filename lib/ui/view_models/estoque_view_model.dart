import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';


class EstoqueViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;


  final _buscaController = BehaviorSubject<String>.seeded('');


  EstoqueViewModel(this._repository);

  Stream<List<Produto>> get produtosFiltrados =>
      Rx.combineLatest2(_repository.getAllProducts(), _buscaController.stream,
              (List<Produto> produtos, String termoBusca) {


            if (termoBusca.isEmpty) {

              produtos.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
              return produtos;
            }

            final termoBuscaLower = termoBusca.toLowerCase();
            final produtosFiltrados = produtos.where((produto) {
              return produto.nome.toLowerCase().contains(termoBuscaLower) ||
                  produto.categoria.toLowerCase().contains(termoBuscaLower);
            }).toList();


            produtosFiltrados.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
            return produtosFiltrados;
          });

  void setBuscaQuery(String query) {
    _buscaController.sink.add(query);
  }

  int diasAteVencer(DateTime validade) {
    final hoje = DateTime.now();

    final dataValidadeZerada = DateTime(validade.year, validade.month, validade.day);
    final hojeZerado = DateTime(hoje.year, hoje.month, hoje.day);

    return dataValidadeZerada.difference(hojeZerado).inDays;
  }

  Map<String, dynamic> getProdutoStatus(Produto produto) {
    final dias = diasAteVencer(produto.validade);
    final dataFormatada = DateFormat('dd/MM/yyyy').format(produto.validade);

    if (dias < 0) {
      return {'color': const Color(0xFFF44336), 'text': "Vencido há ${dias.abs()} ${dias.abs() == 1 ? 'dia' : 'dias'}"};
    } else if (dias == 0) {
      return {'color': const Color(0xFFF44336), 'text': 'Vence hoje'};
    } else if (dias <= 2) {
      return {'color': const Color(0xFFFFC107), 'text': 'Vence em $dias ${dias == 1 ? 'dia' : 'dias'}'};
    } else {
      return {'color': Colors.green, 'text': dataFormatada};
    }
  }



  Future<void> excluirProduto(String id) async {
    try {
      await _repository.deleteProduct(id);
    } catch (e) {
      print("Erro ao excluir produto: $e");
    }
  }

  Future<void> adicionarProduto({
    required String nome,
    required DateTime validade,
    required int quantidade,
    required String categoria,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Erro: Usuário não logado tentando adicionar produto");
      return;
    }

    int iconeAutomatico = _escolherIconePorCategoria(categoria);

    final novoProduto = Produto(
      userId: user.uid,
      nome: nome,
      validade: validade,
      quantidade: quantidade,
      categoria: categoria,
      iconeCodePoint: iconeAutomatico,
    );

    await _repository.addProduct(novoProduto);
  }

  Future<void> aumentarQuantidade(Produto produto) async {
    final produtoEditado = produto.copyWith(quantidade: produto.quantidade + 1);
    await _repository.updateProduct(produtoEditado);
  }

  Future<void> diminuirQuantidade(Produto produto) async {

    if (produto.quantidade > 0) {
      final produtoEditado = produto.copyWith(quantidade: produto.quantidade - 1);
      await _repository.updateProduct(produtoEditado);
    }
  }

  int _escolherIconePorCategoria(String categoria) {
    final cat = categoria.toLowerCase().trim();
    if (cat.contains('ali') || cat.contains('comida')) return Icons.restaurant_menu.codePoint;
    if (cat.contains('limp') || cat.contains('vas')) return Icons.cleaning_services.codePoint;
    if (cat.contains('hig') || cat.contains('banh')) return Icons.soap.codePoint;
    if (cat.contains('eletr')) return Icons.electrical_services.codePoint;
    return Icons.inventory_2.codePoint;
  }

  @override
  void dispose() {
    _buscaController.close();
    super.dispose();
  }
}