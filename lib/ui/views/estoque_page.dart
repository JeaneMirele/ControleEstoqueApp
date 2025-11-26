import 'package:controle_estoque_app/ui/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produto.dart';
import '../view_models/estoque_view.dart';

class EstoquePage extends StatelessWidget {
  const EstoquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estoque Residencial"),
        backgroundColor: const Color(0xFF13EC5B), // Verde
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(currentPage: 'estoque'), // Drawer reutilizável
      body: Consumer<EstoqueViewModel>(
        builder: (context, viewModel, child) {
          return StreamBuilder<List<Produto>>(
            stream: viewModel.listaDeProdutos,
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar dados."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Nenhum produto.\nClique no + para adicionar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final produtos = snapshot.data!;

              return ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final produto = produtos[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 3,
                    child: ListTile(

                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF13EC5B).withOpacity(0.2),
                        child: Icon(produto.getIcone(), color: const Color(0xFF13EC5B)),
                      ),
                      title: Text(
                        produto.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${produto.categoria} | Val: ${produto.validade}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              produto.quantidade,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              viewModel.excluirProduto(produto.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAdicionar(context),
        backgroundColor: const Color(0xFF13EC5B), // Verde
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _mostrarDialogoAdicionar(BuildContext context) {
    final nomeController = TextEditingController();
    final qtdController = TextEditingController();
    final catController = TextEditingController();
    final validadeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Produto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome (ex: Arroz)"),
              ),
              TextField(
                controller: qtdController,
                decoration: const InputDecoration(labelText: "Quantidade"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: "Categoria (ex: Alimentos)"),
              ),
              TextField(
                controller: validadeController,
                decoration: const InputDecoration(labelText: "Validade (ex: 10/12)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EstoqueViewModel>().adicionarProduto(
                nome: nomeController.text,
                quantidade: qtdController.text,
                categoria: catController.text,
                validade: validadeController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF13EC5B), // Verde
              foregroundColor: Colors.white,
            ),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
