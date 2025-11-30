import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notifications_service.dart';
import '../../data/services/user_service.dart';
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

    // 1. Instanciação dos Serviços e Repositories (Camada de Dados)
    // Esses podem ser criados aqui pois não dependem de estado do usuário (são Singletons ou Stateless)
    final firestoreService = FirestoreService();
    final authService = AuthService();
    final notificationService = PushNotificationService();
    final userService = UserService();

    final produtoRepository = ProdutoRepository(firestoreService);
    final shoppingListRepository = ShoppingListRepository(firestoreService);

    return ConfigureProviders(providers: [

      // 2. Disponibiliza Serviços e Repositories para a árvore de widgets
      Provider<FirestoreService>.value(value: firestoreService),
      Provider<AuthService>.value(value: authService),
      Provider<PushNotificationService>.value(value: notificationService),
      Provider<UserService>.value(value: userService),

      Provider<ProdutoRepository>.value(value: produtoRepository),
      Provider<ShoppingListRepository>.value(value: shoppingListRepository),

      // 3. ViewModels (Camada de Apresentação)

      // AuthViewModel: Gerencia o estado do usuário
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => AuthViewModel(authService, notificationService, userService),
      ),


      // Ele observa o AuthViewModel. Se o usuário logar, ele recria o EstoqueViewModel com o familyId.
      ChangeNotifierProxyProvider<AuthViewModel, EstoqueViewModel>(
        create: (_) => EstoqueViewModel(
          repository: produtoRepository,
          shoppingListRepository: shoppingListRepository,
          userId: '',
          familyId: '',
        ),
        update: (_, authViewModel, previousViewModel) {

          final userId = authViewModel.usuario?.uid ?? '';
          final familyId = authViewModel.familyId ?? '';


          return EstoqueViewModel(
            repository: produtoRepository,
            shoppingListRepository: shoppingListRepository,
            userId: userId,
            familyId: familyId,
          );
        },
      ),


      ChangeNotifierProvider<ShoppingListViewModel>(
        create: (_) => ShoppingListViewModel(shoppingListRepository),
      ),


      ChangeNotifierProvider<ExpirationAlertsViewModel>(
        create: (_) => ExpirationAlertsViewModel(produtoRepository),
      ),
    ]);
  }
}