import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Produto.dart';
import '../view_models/estoque_view.dart';


class EstoquePage extends StatelessWidget {
  const EstoquePage({super.key});

  Color statusColor(String date) {
    DateTime validade = DateTime.parse(date.split('/').reversed.join('-'));
    DateTime agora = DateTime.now();
    final diff = validade.difference(agora).inDays;

    if (diff <= 0) return Colors.red;
    if (diff <= 60) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Meu Estoque',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Consumer<EstoqueViewModel>(
        builder: (context, vm, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.produtos.length,
            itemBuilder: (context, i) {
              final item = vm.produtos[i];

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nome, style: const TextStyle(fontSize: 18)),
                            Text(
                              'Validade: ${item.validade}',
                              style: const TextStyle(color: Colors.orange),
                            ),
                            Text(item.quantidade,
                                style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: statusColor(item.validade),
                          shape: BoxShape.circle,
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 25)
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          final vm = context.read<EstoqueViewModel>();
          vm.adicionarProduto(
            Produto(
              nome: 'Novo Item',
              validade: '01/01/2026',
              quantidade: '1 unidade',
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
