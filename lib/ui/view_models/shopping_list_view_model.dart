import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../models/shopping_list_item.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListRepository _repository;


  final _searchQuery = BehaviorSubject<String>.seeded('');

  ShoppingListViewModel(this._repository) {

    _initializeStream();
  }

  late Stream<List<ShoppingListItem>> shoppingList;

  void _initializeStream() {

    shoppingList = Rx.combineLatest2(
      _repository.getShoppingList(),
      _searchQuery.stream.debounceTime(const Duration(milliseconds: 300)),
      (List<ShoppingListItem> items, String query) {
        if (query.isEmpty) {
          return items;
        } else {
          final lowerCaseQuery = query.toLowerCase();
          return items.where((item) {
            return item.nome.toLowerCase().contains(lowerCaseQuery) ||
                   item.categoria.toLowerCase().contains(lowerCaseQuery);
          }).toList();
        }
      },
    ).shareReplay(maxSize: 1);
  }


  void setSearchQuery(String query) {
    _searchQuery.add(query);
  }

  Future<void> addItem(ShoppingListItem item) {
    return _repository.addItem(item);
  }

  void toggleItemChecked(String id, bool isChecked) {
    _repository.updateItem(id, isChecked);
  }

  void deleteItem(String id) {
    _repository.deleteItem(id);
  }


  @override
  void dispose() {
    _searchQuery.close();
    super.dispose();
  }
}
