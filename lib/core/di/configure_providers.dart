import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/repositories/produto_repository.dart';
import '../../data/services/firestore_service.dart';
import '../../ui/view_models/estoque_view.dart';
import '../../ui/view_models/expiration_alerts_view_model.dart';
import '../../ui/view_models/shopping_list_view_model.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {

    final firestoreService = FirestoreService();
    final produtoRepository = ProdutoRepository(firestoreService);
    final estoqueViewModel = EstoqueViewModel(produtoRepository);
    final shoppingListViewModel = ShoppingListViewModel(produtoRepository);
    final expirationAlertsViewModel = ExpirationAlertsViewModel(produtoRepository);

    return ConfigureProviders(providers: [
      Provider<FirestoreService>.value(value: firestoreService),
      Provider<ProdutoRepository>.value(value: produtoRepository),
      ChangeNotifierProvider<EstoqueViewModel>.value(value: estoqueViewModel),
      ChangeNotifierProvider<ShoppingListViewModel>.value(value: shoppingListViewModel),
      ChangeNotifierProvider<ExpirationAlertsViewModel>.value(value: expirationAlertsViewModel),
    ]);
  }
}
