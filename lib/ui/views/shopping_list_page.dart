import 'package:controle_estoque_app/ui/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produto.dart';
import '../view_models/shopping_list_view_model.dart';
import '../components/shopping_item_tile.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'shopping_list'), // Drawer reutilizável
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
        backgroundColor: const Color(0xFF13EC5B), // Verde
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ShoppingListViewModel>(
        builder: (context, viewModel, child) {
          return StreamBuilder<List<Produto>>(
            stream: viewModel.listaDeCompras,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar a lista."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final todosItens = snapshot.data ?? [];
              final aComprar = todosItens.where((p) => !p.comprado).toList();
              final comprados = todosItens.where((p) => p.comprado).toList();

              if (todosItens.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    if (aComprar.isNotEmpty)
                      _buildSection('Gerado Automaticamente', aComprar, viewModel),
                    if (comprados.isNotEmpty)
                      _buildSection('Comprados', comprados, viewModel),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF13EC5B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_checkout, size: 60, color: Color(0xFF13EC5B)),
          SizedBox(height: 16),
          Text('Sua despensa está cheia!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Nenhum item em falta no momento.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar na lista...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Produto> produtos, ShoppingListViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ShoppingItemTile(
                produto: produto,
                comprado: produto.comprado,
                onChanged: (comprado) => viewModel.toggleComprado(produto),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
