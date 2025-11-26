import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_estoque_app/ui/components/app_drawer.dart';
import 'package:controle_estoque_app/ui/view_models/estoque_view_model.dart';
import 'package:controle_estoque_app/models/produto.dart';
import 'package:controle_estoque_app/ui/components/estoque_item_card.dart';
import 'package:controle_estoque_app/ui/views/add_produto_page.dart';

class EstoquePage extends StatelessWidget {
  const EstoquePage({Key? key}) : super(key: key);

  void _mostrarDialogoDelecao(BuildContext context, Produto produto) {
    final viewModel = Provider.of<EstoqueViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja remover "${produto.nome}" do estoque? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
              onPressed: () {
                viewModel.excluirProduto(produto.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${produto.nome}" foi removido do estoque.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EstoqueViewModel>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color searchBarColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Estoque'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(currentPage: 'estoque'),
      body: Column(
        children: [
           Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (value) {
                  viewModel.setBuscaQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar no estoque...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search),
                  ),
                  prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
                  filled: true,
                  fillColor: searchBarColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Produto>>(
              stream: viewModel.produtosFiltrados,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                     child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Seu estoque está vazio',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Adicione produtos para começar a organizar sua despensa.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final produtos = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, left: 12, right: 12),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return EstoqueItemCard(
                      produto: produto,
                      onAumentar: () => viewModel.aumentarQuantidade(produto),
                      onDiminuir: () => viewModel.diminuirQuantidade(produto),
                      onLongPress: () => _mostrarDialogoDelecao(context, produto),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddProdutoPage()),
          );
        },
        child: const Icon(Icons.add),
        heroTag: 'add_produto_fab',
      ),
    );
  }
}
