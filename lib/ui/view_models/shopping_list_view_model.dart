import 'package:flutter/material.dart';
import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;

  ShoppingListViewModel(this._repository);

  Stream<List<Produto>> get listaDeCompras => _repository.getShoppingList();

  void toggleComprado(Produto produto) {
    produto.comprado = !produto.comprado;
    _repository.updateProduct(produto);
    notifyListeners();
  }
}
