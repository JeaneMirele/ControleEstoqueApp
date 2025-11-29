import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_estoque_app/ui/components/app_drawer.dart';
import 'package:controle_estoque_app/ui/view_models/estoque_view_model.dart';
import 'package:controle_estoque_app/models/produto.dart';
import 'package:controle_estoque_app/ui/components/estoque_item_card.dart';
import 'package:controle_estoque_app/ui/views/add_produto_page.dart';

class EstoquePage extends StatelessWidget {
  const EstoquePage({Key? key}) : super(key: key);


  void _mostrarDialogoDelecao(BuildContext context, Produto produto, EstoqueViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja remover "${produto.nome}" do estoque?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                if (produto.id != null) {
                  viewModel.excluirProduto(produto.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${produto.nome}" removido.')),
                  );
                }
                Navigator.of(context).pop();
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


                    return Dismissible(

                      key: Key(produto.id ?? UniqueKey().toString()),


                      direction: DismissDirection.endToStart,


                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                      ),


                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirmar Exclusão"),
                              content: Text("Tem certeza que deseja apagar '${produto.nome}'?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("Excluir"),
                                ),
                              ],
                            );
                          },
                        );
                      },


                      onDismissed: (direction) {
                        if (produto.id != null) {
                          viewModel.excluirProduto(produto.id!);


                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${produto.nome} excluído.'),
                              action: SnackBarAction(
                                label: "Desfazer",
                                onPressed: () {

                                  viewModel.adicionarProduto(
                                    nome: produto.nome,
                                    quantidade: produto.quantidade,
                                    categoria: produto.categoria,
                                    validade: produto.validade,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },


                      child: EstoqueItemCard(
                        produto: produto,
                        onAumentar: () => viewModel.aumentarQuantidade(produto),
                        onDiminuir: () => viewModel.diminuirQuantidade(produto),
                        onLongPress: () => _mostrarDialogoDelecao(context, produto, viewModel),
                      ),
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