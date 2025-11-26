import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produto.dart';
import '../view_models/expiration_alerts_view_model.dart';
import '../components/app_drawer.dart';

class ExpirationAlertsPage extends StatelessWidget {
  const ExpirationAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExpirationAlertsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Vencimento'),
        backgroundColor: const Color(0xFF13EC5B),
      ),
      drawer: const AppDrawer(currentPage: 'Alertas'),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.produtos.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    if (viewModel.vencendoHoje.isNotEmpty)
                      _buildSection(context, 'Vencendo Hoje', viewModel.vencendoHoje),
                    if (viewModel.vencendoNaSemana.isNotEmpty)
                      _buildSection(context, 'Vencendo nesta Semana', viewModel.vencendoNaSemana),
                    if (viewModel.proximos15dias.isNotEmpty)
                      _buildSection(context, 'Próximos 15 dias', viewModel.proximos15dias),
                  ],
                ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Produto> produtos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...produtos.map((produto) => _buildProductTile(context, produto)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductTile(BuildContext context, Produto produto) {
    // Correção: Acessando o viewModel e o método público a partir do context
    final viewModel = Provider.of<ExpirationAlertsViewModel>(context, listen: false);
    final dias = viewModel.diasAteVencer(produto.validade);
    
    final Color borderColor;
    final Color dateColor;

    if (dias <= 0) {
      borderColor = Colors.red;
      dateColor = Colors.red;
    } else if (dias <= 7) {
      borderColor = Colors.orange;
      dateColor = Colors.orange;
    } else {
      borderColor = Colors.yellow;
      dateColor = Colors.yellow[700]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: ListTile(
        title: Text(produto.nome),
        subtitle: Text('Vence em $dias dia(s) - ${produto.quantidade}'),
        trailing: const Icon(Icons.more_vert),
        tileColor: Theme.of(context).cardColor,
        leading: CircleAvatar(
          backgroundColor: dateColor,
          child: Text(
            dias.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Tudo em ordem!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum produto está próximo do vencimento.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
