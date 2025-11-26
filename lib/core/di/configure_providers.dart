import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/repositories/produto_repository.dart';
import '../../data/repositories/shopping_list_repository.dart'; // Importado
import '../../data/services/firestore_service.dart';
import '../../ui/view_models/estoque_view_model.dart';
import '../../ui/view_models/expiration_alerts_view_model.dart';
import '../../ui/view_models/shopping_list_view_model.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    // Serviços e Repositórios
    final firestoreService = FirestoreService();
    final produtoRepository = ProdutoRepository(firestoreService);
    final shoppingListRepository = ShoppingListRepository(firestoreService); // Criado

    // ViewModels
    final estoqueViewModel = EstoqueViewModel(produtoRepository, shoppingListRepository); // Corrigido
    final shoppingListViewModel = ShoppingListViewModel(shoppingListRepository); // Corrigido
    final expirationAlertsViewModel = ExpirationAlertsViewModel(produtoRepository);

    return ConfigureProviders(providers: [
      // Provedores de baixo nível (serviços, repositórios)
      Provider<FirestoreService>.value(value: firestoreService),
      Provider<ProdutoRepository>.value(value: produtoRepository),
      Provider<ShoppingListRepository>.value(value: shoppingListRepository), // Adicionado

      // Provedores de alto nível (ViewModels)
      ChangeNotifierProvider<EstoqueViewModel>.value(value: estoqueViewModel),
      ChangeNotifierProvider<ShoppingListViewModel>.value(value: shoppingListViewModel),
      ChangeNotifierProvider<ExpirationAlertsViewModel>.value(value: expirationAlertsViewModel),
    ]);
  }
}
