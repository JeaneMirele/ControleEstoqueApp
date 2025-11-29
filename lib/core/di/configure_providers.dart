import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notifications_service.dart';
import '../../data/repositories/produto_repository.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../ui/view_models/estoque_view_model.dart';
import '../../ui/view_models/expiration_alerts_view_model.dart';
import '../../ui/view_models/shopping_list_view_model.dart';
import '../../ui/view_models/auth_view_model.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {

    final firestoreService = FirestoreService();
    final authService = AuthService();
    final notificationService = PushNotificationService();

    final produtoRepository = ProdutoRepository(firestoreService);
    final shoppingListRepository = ShoppingListRepository(firestoreService);


    final estoqueViewModel = EstoqueViewModel(produtoRepository);
    final shoppingListViewModel = ShoppingListViewModel(shoppingListRepository);
    final expirationAlertsViewModel = ExpirationAlertsViewModel(produtoRepository);


    final authViewModel = AuthViewModel(authService, notificationService);

    return ConfigureProviders(providers: [

      Provider<FirestoreService>.value(value: firestoreService),
      Provider<AuthService>.value(value: authService),
      Provider<PushNotificationService>.value(value: notificationService),
      Provider<ShoppingListRepository>.value(value: shoppingListRepository),


      ChangeNotifierProvider<EstoqueViewModel>.value(value: estoqueViewModel),
      ChangeNotifierProvider<ShoppingListViewModel>.value(value: shoppingListViewModel),
      ChangeNotifierProvider<ExpirationAlertsViewModel>.value(value: expirationAlertsViewModel),
      ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
    ]);
  }
}