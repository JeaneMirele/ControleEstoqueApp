import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../models/shopping_list_item.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListRepository _repository;

  // Subject para controlar o termo de busca do usuário
  final _searchQuery = BehaviorSubject<String>.seeded('');

  ShoppingListViewModel(this._repository) {
    // Inicializa o stream combinado
    _initializeStream();
  }

  late Stream<List<ShoppingListItem>> shoppingList;

  void _initializeStream() {
    // Combina o stream da lista de compras do repositório com o stream da busca
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
    ).asBroadcastStream(); // Usa asBroadcastStream para múltiplos ouvintes
  }

  // Função para o usuário atualizar o termo de busca
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

  // Limpa os resources quando o ViewModel for descartado
  @override
  void dispose() {
    _searchQuery.close();
    super.dispose();
  }
}
