import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../models/shopping_list_item.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListRepository _repository;

  ShoppingListViewModel(this._repository);

  Stream<List<ShoppingListItem>> get shoppingList => _repository.getShoppingList();

  Future<void> addItem(ShoppingListItem item) {
    return _repository.addItem(item);
  }

  void toggleItemChecked(String id, bool isChecked) {
    _repository.updateItem(id, isChecked);
    // A UI será atualizada automaticamente pelo Stream, então não é necessário notifyListeners()
  }

  void deleteItem(String id) {
    _repository.deleteItem(id);
  }
}
