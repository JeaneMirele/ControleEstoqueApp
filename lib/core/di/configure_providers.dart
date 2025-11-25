import 'package:controle_estoque_app/ui/view_models/estoque_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


class ConfigureProviders {

  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {

    //final todoService = TodoService();
    //final todoRepository = TodoRepository(todoService);
    final estoqueViewModel = EstoqueViewModel();

    return ConfigureProviders(providers: [
     // Provider<TodoService>.value(value: todoService),
     // Provider<TodoRepository>.value(value: todoRepository),
      ChangeNotifierProvider<EstoqueViewModel>.value(value: egit stoqueViewModel)
    ]);
  }
}