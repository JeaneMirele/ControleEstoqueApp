import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../ui/view_models/auth_view_model.dart';
import '../../models/app_user.dart';

class FamilySettingsPage extends StatefulWidget {
  const FamilySettingsPage({super.key});

  @override
  State<FamilySettingsPage> createState() => _FamilySettingsPageState();
}

class _FamilySettingsPageState extends State<FamilySettingsPage> {
  final _familyIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _familyIdController.dispose();
    super.dispose();
  }

  void _entrarEmFamilia(BuildContext context) async {
    final novoId = _familyIdController.text.trim();
    if (novoId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthViewModel>().entrarEmFamilia(novoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você entrou na nova família com sucesso!')),
      );
      _familyIdController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final familyId = authViewModel.familyId ?? 'Carregando...';

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Família')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com o Código da Família
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Código da sua Família', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SelectableText(
                            familyId,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: familyId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Código copiado!')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Envie este código para quem mora com você.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lista de Membros
            const Text('Membros do Grupo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<AppUser>>(
                stream: authViewModel.getFamilyMembers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum membro encontrado.'));
                  }
                  
                  final members = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isMe = member.id == authViewModel.usuario?.uid;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(member.name?.isNotEmpty == true ? member.name![0].toUpperCase() : '?', 
                                  style: TextStyle(color: Colors.blue.shade800)),
                          ),
                          title: Text(member.name ?? 'Usuário sem nome'),
                          subtitle: Text(member.email),
                          trailing: isMe ? const Chip(label: Text('Eu', style: TextStyle(fontSize: 10))) : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Entrar em outra família
            const Text('Entrar em outro Grupo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _familyIdController,
                    decoration: const InputDecoration(
                      hintText: 'Cole o código aqui',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _entrarEmFamilia(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Entrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
