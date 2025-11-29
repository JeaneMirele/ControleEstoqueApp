import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_list_item.dart';
import '../view_models/shopping_list_view_model.dart';
import '../components/app_drawer.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {

    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
        centerTitle: true,
      ),

      drawer: const AppDrawer(currentPage: 'ShoppingList'),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(

              onChanged: (value) => viewModel.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Buscar na lista...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),


          Expanded(
            child: StreamBuilder<List<ShoppingListItem>>(
              stream: viewModel.shoppingList,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }


                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }


                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Sua lista está vazia!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final itens = snapshot.data!;


                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final item = itens[index];


                    return Dismissible(
                      key: Key(item.id ?? UniqueKey().toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {

                        if (item.id != null) {
                          viewModel.deleteItem(item.id!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${item.nome} removido")),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            item.nome,
                            style: TextStyle(
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              color: item.isChecked ? Colors.grey : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "${item.quantidade} • ${item.categoria}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          value: item.isChecked,
                          activeColor: Colors.green,

                          onChanged: (bool? value) {
                            if (item.id != null && value != null) {
                              viewModel.toggleItemChecked(item.id!, value);
                            }
                          },
                          secondary: _getIconForCategory(item.categoria),
                        ),
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
        onPressed: () => _mostrarDialogoAdicionar(context, viewModel),
        backgroundColor: const Color(0xFF28A745),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Widget _getIconForCategory(String categoria) {
    IconData icon;
    switch (categoria.toLowerCase()) {
      case 'laticínios': icon = Icons.water_drop; break;
      case 'padaria': icon = Icons.breakfast_dining; break;
      case 'frutas': icon = Icons.apple; break;
      default: icon = Icons.shopping_bag; break;
    }
    return Icon(icon, color: Colors.grey);
  }


  void _mostrarDialogoAdicionar(BuildContext context, ShoppingListViewModel viewModel) {
    final nomeController = TextEditingController();
    final qtdController = TextEditingController(text: '1');
    String categoriaSelecionada = 'Geral'; 
    final categorias = ['Geral', 'Laticínios', 'Padaria', 'Frutas', 'Limpeza', 'Outros'];

    showDialog(
      context: context,
      builder: (ctx) {

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome do produto'),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtdController,
                          decoration: const InputDecoration(labelText: 'Qtd'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: categoriaSelecionada,
                          decoration: const InputDecoration(labelText: 'Categoria'),
                          items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            setState(() => categoriaSelecionada = val!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nomeController.text.isNotEmpty) {
                      final novoItem = ShoppingListItem(
                        nome: nomeController.text.trim(),
                        quantidade: qtdController.text.trim(),
                        categoria: categoriaSelecionada,
                        isChecked: false,
                        isAutomatic: false,

                      );


                      viewModel.addItem(novoItem);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Adicionar'),
                )
              ],
            );
          },
        );
      },
    );
  }
}