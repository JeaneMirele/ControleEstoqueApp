import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/estoque_view_model.dart';
import '../view_models/auth_view_model.dart';

class AddProdutoPage extends StatefulWidget {
  const AddProdutoPage({super.key});

  @override
  State<AddProdutoPage> createState() => _AddProdutoPageState();
}

class _AddProdutoPageState extends State<AddProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  DateTime? _validadeSelecionada;
  String _categoriaSelecionada = 'Alimentos';
  bool _isSaving = false;

  final List<String> _categorias = [
    'Alimentos',
    'Higiene',
    'Limpeza',
    'Eletrônicos',
    'Outros'
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _validadeSelecionada) {
      setState(() {
        _validadeSelecionada = picked;
      });
    }
  }

  Future<void> _salvarProduto() async {
    if (_formKey.currentState!.validate() && _validadeSelecionada != null) {
      setState(() {
        _isSaving = true;
      });

      try {

        final authViewModel = context.read<AuthViewModel>();
        final familyId = authViewModel.familyId;

        await context.read<EstoqueViewModel>().adicionarProduto(
          nome: _nomeController.text,
          validade: _validadeSelecionada!,
          quantidade: int.parse(_quantidadeController.text),
          categoria: _categoriaSelecionada,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto adicionado com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else if (_validadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a validade!'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),


              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira a quantidade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),


              InkWell(
                onTap: () => _selecionarData(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de Validade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _validadeSelecionada == null
                        ? 'Selecione a data'
                        : DateFormat('dd/MM/yyyy').format(_validadeSelecionada!),
                    style: TextStyle(
                      color: _validadeSelecionada == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categorias.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoriaSelecionada = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),


              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarProduto,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SALVAR PRODUTO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
