import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_drawer.dart';
import '../components/expiration_alert_card.dart';
import '../view_models/expiration_alerts_view_model.dart';

class ExpirationAlertsPage extends StatelessWidget {
  const ExpirationAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpirationAlertsViewModel>();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Alertas de Vencimento'),
      //   backgroundColor: const Color(0xFF13EC5B),
      // ),
      drawer: const AppDrawer(currentPage: 'ExpirationAlerts'),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
            centerTitle: true,
            title: const Text(
              'Alertas de Vencimento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          viewModel.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : viewModel.produtos.isEmpty
                  ? const SliverFillRemaining(
                      child: _EmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(bottom: 24, top: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final produto = viewModel.produtos[index];
                            return ExpirationAlertCard(produto: produto);
                          },
                          childCount: viewModel.produtos.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tudo em ordem!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum produto está próximo do vencimento nos próximos 15 dias.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
