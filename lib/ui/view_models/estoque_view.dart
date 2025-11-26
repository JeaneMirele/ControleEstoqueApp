import 'package:flutter/material.dart';

import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';

class EstoqueViewModel extends ChangeNotifier {

  final ProdutoRepository _repository;

  EstoqueViewModel(this._repository);

  Stream<List<Produto>> get listaDeProdutos => _repository.getAllProducts();


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