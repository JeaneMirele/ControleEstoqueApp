import 'package:flutter/material.dart';
import '../../models/Produto.dart';


class EstoqueViewModel extends ChangeNotifier {
  List<Produto> produtos = [];

  EstoqueViewModel() {
    carregarItensIniciais();
  }

  void carregarItensIniciais() {
    produtos = [
      Produto(
        nome: 'Ovos',
        validade: '30/12/2024',
        quantidade: '12 unidades',
      ),
      Produto(
        nome: 'Pão de Forma',
        validade: '01/10/2024',
        quantidade: '1 pacote',
      ),
      Produto(
        nome: 'Leite Integral',
        validade: '25/01/2025',
        quantidade: '5 unidades',
      ),
    ];
    notifyListeners();
  }

  void adicionarProduto(Produto p) {
    produtos.add(p);
    notifyListeners();
  }
}
