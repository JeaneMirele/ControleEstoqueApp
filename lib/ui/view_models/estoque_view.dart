import 'dart:async'; // Importar para usar Stream.value

import 'package:flutter/material.dart';

import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';

class EstoqueViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;

  EstoqueViewModel(this._repository);

  // Conexão com Firebase temporariamente desativada.
  // Retorna um stream vazio para evitar que a tela fique carregando indefinidamente.
  // Stream<List<Produto>> get listaDeProdutos => Stream.value([]);
  
  // Para reativar a conexão com o Firebase, comente a linha acima e descomente a linha abaixo.
  Stream<List<Produto>> get listaDeProdutos => _repository.getAllProducts();

  Future<void> adicionarProduto({
    required String nome,
    required String validade,
    required String quantidade,
    required String categoria,
  }) async {
    // Ação de adicionar desativada temporariamente, pois o Firebase não está funcionando.
    // print("Aviso: A funcionalidade de adicionar está desativada enquanto o Firebase estiver offline.");
    // return; // Impede a execução do código abaixo.

    // CÓDIGO ORIGINAL PARA REATIVAR:
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
    // Ação de atualizar desativada temporariamente.
    // print("Aviso: A funcionalidade de atualizar está desativada enquanto o Firebase estiver offline.");
    // return;

    // CÓDIGO ORIGINAL PARA REATIVAR:
    await _repository.updateProduct(produtoEditado);
  }

  Future<void> excluirProduto(String id) async {
    // Ação de excluir desativada temporariamente.
    // print("Aviso: A funcionalidade de excluir está desativada enquanto o Firebase estiver offline.");
    // return;

    // CÓDIGO ORIGINAL PARA REATIVAR:
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
