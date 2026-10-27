import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/MockDatabase.dart';
import '../model/UserModel.dart';
import 'PerfilPesquisaView.dart';

class PesquisaView extends StatefulWidget {
  const PesquisaView({super.key});

  @override
  State<PesquisaView> createState() => _PesquisaViewState();
}

class _PesquisaViewState extends State<PesquisaView> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _usuariosFiltrados = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Inicia sem carregar usuários (lista vazia por padrão)
  }

  void _carregarUsuarios(String query) {
    final uidAtual = FirebaseAuth.instance.currentUser?.uid;
    final emailAtual = FirebaseAuth.instance.currentUser?.email;

    setState(() {
      _query = query.trim();

      // REGRA: Se houver menos de 1 caractere, limpa a lista de resultados
      if (_query.isEmpty) {
        _usuariosFiltrados = [];
        return;
      }

      // Filtra os usuários no MockDatabase se houver ao menos 1 caractere digitado
      _usuariosFiltrados = MockDatabase.usuarios.where((u) {
        final ehUsuarioAtual = u.id == uidAtual || u.email.toLowerCase() == emailAtual?.toLowerCase();
        if (ehUsuarioAtual) return false;

        final nomeCoincide = u.nome.toLowerCase().contains(_query.toLowerCase());
        final emailCoincide = u.email.toLowerCase().contains(_query.toLowerCase());
        return nomeCoincide || emailCoincide;
      }).toList();
    });
  }

  ImageProvider? _obterImageProvider(String? caminhoOuUrl) {
    if (caminhoOuUrl == null || caminhoOuUrl.isEmpty) return null;
    return NetworkImage(caminhoOuUrl);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071835),
      body: SafeArea(
        child: Column(
          children: [
            // --- BARRA DE PESQUISA ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _carregarUsuarios,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome ou e-mail...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _carregarUsuarios('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                ),
              ),
            ),

            // --- EXIBIÇÃO DE RESULTADOS / ESTADOS ---
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      // MENSAGEM QUANDO NADA FOI DIGITADO AINDA
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Digite no mínimo 1 caractere para pesquisar.',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : _usuariosFiltrados.isEmpty
                      ? Center(
                          // MENSAGEM QUANDO DIGITOU ALGO MAS NÃO ENCONTROU
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum usuário encontrado para "$_query"',
                                style: const TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          // LISTA COM OS RESULTADOS ENCONTRADOS
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _usuariosFiltrados.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.white10,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final usuario = _usuariosFiltrados[index];
                            final fotoProvider = _obterImageProvider(usuario.fotoUrl);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blueAccent,
                                backgroundImage: fotoProvider,
                                child: fotoProvider == null
                                    ? Text(
                                        usuario.nome.isNotEmpty
                                            ? usuario.nome[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                usuario.nome,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                usuario.email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white38,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PerfilPesquisaView(usuario: usuario),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}