import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/repositories/produto_repository.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../models/produto.dart';
import '../../models/shopping_list_item.dart';

class EstoqueViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;
  final ShoppingListRepository _shoppingListRepository;

  String _userId;
  String _familyId;

  final _buscaController = BehaviorSubject<String>.seeded('');
  late Stream<List<Produto>> produtosFiltrados;


  EstoqueViewModel({
    required ProdutoRepository repository,
    required ShoppingListRepository shoppingListRepository,
    required String userId,
    required String familyId,
  })  : _repository = repository,
        _shoppingListRepository = shoppingListRepository,
        _userId = userId,
        _familyId = familyId {
    _initStream();
  }

  void _initStream() {
    produtosFiltrados = Rx.combineLatest2(
      _repository.getAllProducts(userId: _userId, familyId: _familyId),
      _buscaController.stream,
      _filtrarEOrdenarProdutos,
    ).asBroadcastStream();
  }

  void updateStream(String userId, String familyId) {
    _userId = userId;
    _familyId = familyId;
    _initStream();
    notifyListeners();
  }

  List<Produto> _filtrarEOrdenarProdutos(List<Produto> produtos, String termoBusca) {
    if (termoBusca.isEmpty) {
      produtos.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
      return produtos;
    }

    final termoBuscaLower = termoBusca.toLowerCase();
    final filtrados = produtos.where((produto) {
      return produto.nome.toLowerCase().contains(termoBuscaLower) ||
          produto.categoria.toLowerCase().contains(termoBuscaLower);
    }).toList();

    filtrados.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
    return filtrados;
  }

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

    int iconeAutomatico = _escolherIconePorCategoria(categoria);

    final novoProduto = Produto(
      userId: _userId,
      familyId: _familyId,
      nome: nome,
      validade: validade,
      quantidade: quantidade,
      categoria: categoria,
      iconeCodePoint: iconeAutomatico,
    );

    await _repository.addProduct(novoProduto);
  }

  Future<void> aumentarQuantidade(Produto produto) async {
    final novaQuantidade = produto.quantidade + 1;

    final produtoEditado = produto.copyWith(quantidade: novaQuantidade);
    await _repository.updateProduct(produtoEditado);


    if (novaQuantidade > 1) {
      try {
        final item = await _shoppingListRepository.findItemByProductName(
            produto.nome,
            _userId, // Usa da classe
            familyId: produto.familyId
        );


        if (item != null && item.isAutomatic && !item.isChecked && item.id != null) {
          await _shoppingListRepository.deleteItem(item.id!);
        }
      } catch (e) {
        print("Erro lista compras: $e");
      }
    }
  }

  Future<void> diminuirQuantidade(Produto produto) async {
    if (produto.quantidade > 0) {
      final novaQuantidade = produto.quantidade - 1;
      final produtoEditado = produto.copyWith(quantidade: novaQuantidade);

      await _repository.updateProduct(produtoEditado);


      if (novaQuantidade <= 1) {
        try {

          final itemExistente = await _shoppingListRepository.findItemByProductName(
              produto.nome, _userId, familyId: produto.familyId
          );

          if (itemExistente == null) {
            final novoItem = ShoppingListItem(
              nome: produto.nome,
              quantidade: "1",
              categoria: produto.categoria,
              isAutomatic: true,
              userId: _userId,
              familyId: produto.familyId,
              isChecked: false,
            );
            await _shoppingListRepository.addItem(novoItem);
          }
        } catch (e) {
          print("Erro lista compras: $e");
        }
      }
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
