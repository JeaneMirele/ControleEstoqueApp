import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/produto_repository.dart';
import '../../models/produto.dart';

class ExpirationAlertsViewModel extends ChangeNotifier {
  final ProdutoRepository _repository;
  final String? userId;
  final String? familyId;
  StreamSubscription<List<Produto>>? _produtosSubscription;

  ExpirationAlertsViewModel(this._repository, {this.userId, this.familyId}) {
    _fetchProdutos();
  }

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;


  List<Produto> get vencendoHoje => _produtos.where((p) => diasAteVencer(p.validade!) <= 0).toList();

  List<Produto> get vencendoNaSemana => _produtos.where((p) {
    final dias = diasAteVencer(p.validade!);
    return dias > 0 && dias <= 7;
  }).toList();

  List<Produto> get proximos15dias => _produtos.where((p) {
    final dias = diasAteVencer(p.validade!);
    return dias > 7 && dias <= 15;
  }).toList();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _fetchProdutos() {
    _isLoading = true;
    notifyListeners();

    _produtosSubscription = _repository.getAllProducts(userId: userId, familyId: familyId).listen((produtos) {

      _produtos = produtos.where((p) =>
      p.validade != null && diasAteVencer(p.validade!) <= 15 && p.quantidade > 0
      ).toList();

      _produtos.sort((a, b) => diasAteVencer(a.validade!).compareTo(diasAteVencer(b.validade!)));

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = "Falha ao carregar produtos: $error";
      notifyListeners();
    });
  }


  int diasAteVencer(DateTime dataValidade) {
    final hoje = DateTime.now();


    final dataValidadeZerada = DateTime(dataValidade.year, dataValidade.month, dataValidade.day);
    final hojeZerado = DateTime(hoje.year, hoje.month, hoje.day);

    return dataValidadeZerada.difference(hojeZerado).inDays;
  }

  Map<String, dynamic> getAlertStatus(Produto produto) {

    final dias = diasAteVencer(produto.validade!);

    if (dias < 0) {
      return {'text': 'Vencido há ${dias.abs()} dia(s)', 'color': Colors.red.shade700};
    } else if (dias == 0) {
      return {'text': 'Vence Hoje', 'color': Colors.red.shade700};
    } else if (dias <= 7) {
      return {'text': 'Vence em $dias dia(s)', 'color': Colors.orange.shade700};
    } else {
      return {'text': 'Vence em $dias dia(s)', 'color': Colors.amber.shade800};
    }
  }

  @override
  void dispose() {
    _produtosSubscription?.cancel();
    super.dispose();
  }
}