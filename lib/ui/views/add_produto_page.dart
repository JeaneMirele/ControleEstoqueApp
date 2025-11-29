import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/estoque_view_model.dart';

class AddProdutoPage extends StatefulWidget {
  const AddProdutoPage({super.key});

  @override
  State<AddProdutoPage> createState() => _AddProdutoPageState();
}

class _AddProdutoPageState extends State<AddProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();


  DateTime? _dataValidadeSelecionada;

  int _quantidade = 1;
  String? _categoriaSelecionada;

  final List<String> _categorias = ['Laticínios', 'Grãos', 'Limpeza', 'Bebidas', 'Outros'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {

        _dataValidadeSelecionada = picked;
        _validadeController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Produto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome do Produto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(hintText: 'Ex: Leite Integral', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),


              const Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.inventory_2_outlined),
                    const Text('Quantidade', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _quantidade > 1 ? _quantidade-- : null)),
                        Text('$_quantidade', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _quantidade++)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),


              const Text('Data de Validade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _validadeController,
                decoration: const InputDecoration(
                  hintText: 'Selecione a data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty || _dataValidadeSelecionada == null) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),


              const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Selecione a categoria'),
                value: _categoriaSelecionada,
                items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _categoriaSelecionada = value),
                validator: (value) => (value == null) ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {

            if (_formKey.currentState!.validate() && _dataValidadeSelecionada != null) {


              context.read<EstoqueViewModel>().adicionarProduto(
                nome: _nomeController.text,
                quantidade: _quantidade,
                categoria: _categoriaSelecionada!,
                validade: _dataValidadeSelecionada!,
              );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28A745),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Salvar Produto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}