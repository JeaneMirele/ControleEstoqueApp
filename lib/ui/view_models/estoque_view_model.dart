
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

  // Controller para o termo de busca
  final _buscaController = BehaviorSubject<String>.seeded('');

  // Stream que combina a lista de produtos com a busca
  Stream<List<Produto>> get produtosFiltrados =>
      Rx.combineLatest2(_repository.getAllProducts(), _buscaController.stream,
          (List<Produto> produtos, String termoBusca) {
        
        // Dispara a verificação de estoque para a lista de compras
        _verificarEstoqueParaListaDeCompras(produtos);

        if (termoBusca.isEmpty) {
          // Ordena a lista original se não houver busca
          produtos.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
          return produtos;
        }

        // Filtra os produtos com base no termo de busca
        final termoBuscaLower = termoBusca.toLowerCase();
        final produtosFiltrados = produtos.where((produto) {
          return produto.nome.toLowerCase().contains(termoBuscaLower) ||
                 produto.categoria.toLowerCase().contains(termoBuscaLower);
        }).toList();

        // Ordena a lista filtrada
        produtosFiltrados.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));
        return produtosFiltrados;
      });

  EstoqueViewModel(this._repository, this._shoppingListRepository);

  // --- Funções de Lógica de Negócio ---

  // Método para atualizar o termo de busca
  void setBuscaQuery(String query) {
    _buscaController.sink.add(query);
  }

  // Adicionando a lógica de status de validade
  int diasAteVencer(String dataValidade) {
    try {
      final format = DateFormat("dd/MM/yyyy");
      final validade = format.parse(dataValidade);
      final hoje = DateTime.now();
      final hojeZerado = DateTime(hoje.year, hoje.month, hoje.day);
      return validade.difference(hojeZerado).inDays;
    } catch (e) {
      return 9999; // Retorna um número grande para datas inválidas
    }
  }

  Map<String, dynamic> getProdutoStatus(Produto produto) {
    final dias = diasAteVencer(produto.validade);
    
    if (dias < 0) {
      return {'color': const Color(0xFFF44336), 'text': "Vencido há ${dias.abs()} ${dias.abs() == 1 ? 'dia' : 'dias'}"};
    } else if (dias == 0) {
      return {'color': const Color(0xFFF44336), 'text': 'Vence hoje'};
    } else if (dias <= 7) {
      return {'color': const Color(0xFFFFC107), 'text': 'Vence em $dias ${dias == 1 ? 'dia' : 'dias'}'};
    } else {
      return {'color': Colors.green, 'text': produto.validade};
    }
  }

  // Método CORRIGIDO que verifica o estoque
  Future<void> _verificarEstoqueParaListaDeCompras(List<Produto> produtos) async {
    for (final produto in produtos) {
      // produto.quantidade agora é um int
      if (produto.quantidade <= 1) {
        final itemParaCompra = ShoppingListItem(
          nome: produto.nome,
          // O modelo ShoppingListItem espera uma String para quantidade, então convertemos.
          // Adicionamos '1' unidade para compra.
          quantidade: '1', 
          categoria: produto.categoria,
          isAutomatic: true,
        );
        await _shoppingListRepository.addItem(itemParaCompra);
      }
    }
  }

  // Método CORRIGIDO para adicionar produto
  Future<void> adicionarProduto({
    required String nome,
    required String validade,
    required String quantidade, // Recebe como String da UI
    required String categoria,
  }) async {
    int iconeAutomatico = _escolherIconePorCategoria(categoria);

    final novoProduto = Produto(
      nome: nome,
      validade: validade,
      // Converte a String para int antes de salvar
      quantidade: int.tryParse(quantidade) ?? 1, 
      categoria: categoria,
      iconeCodePoint: iconeAutomatico,
    );

    await _repository.addProduct(novoProduto);
  }

  // --- Funções de Manipulação de Dados ---
  
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

  // Libera os recursos do controller
  @override
  void dispose() {
    _buscaController.close();
    super.dispose();
  }
}
