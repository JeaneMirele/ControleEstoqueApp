import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/produto_repository.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../models/produto.dart';
import '../../models/shopping_list_item.dart';

class EstoqueViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;
  final ShoppingListRepository _shoppingListRepository;

  EstoqueViewModel(this._repository, this._shoppingListRepository);

  Stream<List<Produto>> get listaDeProdutos {
    // Intercepta o stream de produtos para adicionar a lógica da lista de compras
    return _repository.getAllProducts().map((produtos) {
      _verificarEstoqueParaListaDeCompras(produtos);
      return produtos;
    });
  }

  // Método que verifica o estoque e adiciona itens à lista de compras se necessário
  Future<void> _verificarEstoqueParaListaDeCompras(List<Produto> produtos) async {
    for (final produto in produtos) {
      final quantidade = int.tryParse(produto.quantidade) ?? 0;
      if (quantidade <= 1) {
        final itemParaCompra = ShoppingListItem(
          nome: produto.nome,
          quantidade: produto.quantidade, // Adicionando a quantidade
          categoria: produto.categoria,
        );
        // O repositório já tem a lógica para não adicionar itens duplicados
        await _shoppingListRepository.addItem(itemParaCompra);
      }
    }
  }

  Future<void> adicionarProduto({
    required String nome,
    required String validade,
    required String quantidade,
    required String categoria,
  }) async {
    int iconeAutomatico = _escolherIconePorCategoria(categoria);

    final novoProduto = Produto(
      nome: nome,
      validade: validade,
      quantidade: quantidade,
      categoria: categoria,
      iconeCodePoint: iconeAutomatico,
    );

    await _repository.addProduct(novoProduto);
  }

  Future<void> atualizarProduto(Produto produtoEditado) async {
    await _repository.updateProduct(produtoEditado);
  }

  Future<void> excluirProduto(String id) async {
    await _repository.deleteProduct(id);
  }

  int _escolherIconePorCategoria(String categoria) {
    final cat = categoria.toLowerCase().trim();

    if (cat.contains('ali') || cat.contains('comida')) {
      return Icons.restaurant_menu.codePoint;
    } else if (cat.contains('limp') || cat.contains('vas')) {
      return Icons.cleaning_services.codePoint;
    } else if (cat.contains('hig') || cat.contains('banh')) {
      return Icons.soap.codePoint;
    } else if (cat.contains('eletr')) {
      return Icons.electrical_services.codePoint;
    } else {
      return Icons.inventory_2.codePoint;
    }
  }
}
