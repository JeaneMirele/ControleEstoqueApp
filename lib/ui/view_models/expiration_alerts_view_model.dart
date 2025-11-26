import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';

class ExpirationAlertsViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;
  StreamSubscription<List<Produto>>? _produtosSubscription;

  ExpirationAlertsViewModel(this._repository) {
    _fetchProdutos();
  }

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  List<Produto> get vencendoHoje => _produtos.where((p) => diasAteVencer(p.validade) == 0).toList();
  List<Produto> get vencendoNaSemana => _produtos.where((p) {
    final dias = diasAteVencer(p.validade);
    return dias > 0 && dias <= 7;
  }).toList();
  List<Produto> get proximos15dias => _produtos.where((p) {
    final dias = diasAteVencer(p.validade);
    return dias > 7 && dias <= 15;
  }).toList();

  // Inicia como 'false' para não mostrar o loading, já que a busca está desativada.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _fetchProdutos() {
    // A busca de dados do Firebase está temporariamente desativada.
    // A lista de produtos permanecerá vazia e o estado de carregamento é falso.
    
    /* CÓDIGO ORIGINAL PARA REATIVAR O FIREBASE DEPOIS:
    _isLoading = true;
    notifyListeners();

    _produtosSubscription = _repository.getProdutosStream().listen((produtos) {
      _produtos = produtos.where((p) => diasAteVencer(p.validade) <= 15 && diasAteVencer(p.validade) >= 0).toList();
      
      _produtos.sort((a, b) => diasAteVencer(a.validade).compareTo(diasAteVencer(b.validade)));

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = "Falha ao carregar produtos: $error";
      notifyListeners();
    });
    */
  }

  int diasAteVencer(String dataValidade) {
    try {
      final parts = dataValidade.split('/');
      if (parts.length != 3) return 999;
      final dia = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      final ano = int.parse(parts[2]);
      final data = DateTime(ano, mes, dia);
      final hoje = DateTime.now();
      final difference = data.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
      return difference;
    } catch (e) {
      return 999; // Retorna um número grande se a data for inválida
    }
  }

  @override
  void dispose() {
    _produtosSubscription?.cancel();
    super.dispose();
  }
}
