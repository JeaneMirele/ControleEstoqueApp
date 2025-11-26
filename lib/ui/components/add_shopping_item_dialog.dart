import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_list_item.dart';
import '../view_models/shopping_list_view_model.dart';

class AddShoppingItemDialog extends StatefulWidget {
  const AddShoppingItemDialog({Key? key}) : super(key: key);

  @override
  _AddShoppingItemDialogState createState() => _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState extends State<AddShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _quantidade = '1';
  String _categoria = 'Outros';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Item à Lista'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
                onSaved: (value) => _nome = value!,
              ),
              TextFormField(
                initialValue: _quantidade,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  return null;
                },
                onSaved: (value) => _quantidade = value!,
              ),
              TextFormField(
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                onSaved: (value) => _categoria = value!,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Adicionar'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newItem = ShoppingListItem(
                nome: _nome,
                quantidade: _quantidade,
                categoria: _categoria,
              );
              // Usa o Provider para encontrar o ViewModel e chamar o método
              Provider.of<ShoppingListViewModel>(context, listen: false).addItem(newItem);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
