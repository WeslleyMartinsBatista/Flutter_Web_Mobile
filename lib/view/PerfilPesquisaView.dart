import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/UserModel.dart';
import '../model/PublicacaoModel.dart';
import '../service/PublicacaoService.dart';
import '../service/SeguirService.dart';
import 'ChatConversaView.dart';
import 'PublicacaoDetalheView.dart';

class PerfilPesquisaView extends StatefulWidget {
  final UserModel usuario;

  const PerfilPesquisaView({super.key, required this.usuario});

  @override
  State<PerfilPesquisaView> createState() => _PerfilPesquisaViewState();
}

class _PerfilPesquisaViewState extends State<PerfilPesquisaView> {
  final PublicacaoService _publicacaoService = PublicacaoService();
  final SeguirService _seguirService = SeguirService();

  List<PublicacaoModel> _publicacoesUsuario = [];
  bool _estaSeguindo = false;
  late String _meuId;

  static const double _alturaBanner = 100.0;
  static const double _raioAvatar = 40.0;

  @override
  void initState() {
    super.initState();
    _meuId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _publicacoesUsuario = _publicacaoService.obterPublicacoesDoUsuario(
        widget.usuario.id,
      );
      _estaSeguindo = _seguirService.estaSeguindo(_meuId, widget.usuario.id);
    });
  }

  void _alternarAcaoSeguir() {
    _seguirService.alternarSeguir(
      meuId: _meuId,
      usuarioAlvoId: widget.usuario.id,
    );
    setState(() {
      _estaSeguindo = !_estaSeguindo;
    });
  }

  ImageProvider? _obterImageProvider(String? caminhoOuUrl) {
    if (caminhoOuUrl == null || caminhoOuUrl.isEmpty) return null;
    return NetworkImage(caminhoOuUrl);
  }

  Widget _construirColunaMetrica(String valor, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _construirDivisorVertical() {
    return Container(height: 20, width: 1, color: Colors.white24);
  }

  @override
  Widget build(BuildContext context) {
    final bannerProvider = _obterImageProvider(widget.usuario.bannerUrl);
    final fotoProvider = _obterImageProvider(widget.usuario.fotoUrl);

    // Contagens dinâmicas baseadas nas listas do modelo
    final int totalSeguidores = widget.usuario.seguidores.length;
    final int totalSeguindo = widget.usuario.seguindo.length;

    return Scaffold(
      backgroundColor: const Color(0xFF071835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.usuario.nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BANNER + FOTO ---
            SizedBox(
              height: _alturaBanner + _raioAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: _alturaBanner,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: bannerProvider == null
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0A2A55), Color(0xFF1E5288)],
                            )
                          : null,
                      image: bannerProvider != null
                          ? DecorationImage(
                              image: bannerProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: _alturaBanner - _raioAvatar,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF071835),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: _raioAvatar,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: fotoProvider,
                        child: fotoProvider == null
                            ? Text(
                                widget.usuario.nome.isNotEmpty
                                    ? widget.usuario.nome[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- NOME E E-MAIL ---
            Text(
              widget.usuario.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.usuario.email,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),

            // --- BIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                widget.usuario.bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- MÉTRICAS REATIVAS DE SEGUIDORES/SEGUINDO/PUBLICAÇÕES ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _construirColunaMetrica(
                    '${_publicacoesUsuario.length}',
                    'Publicações',
                  ),
                  _construirDivisorVertical(),
                  _construirColunaMetrica('$totalSeguidores', 'Seguidores'),
                  _construirDivisorVertical(),
                  _construirColunaMetrica('$totalSeguindo', 'Seguindo'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- BOTÕES DE AÇÃO (SEGUIR / MENSAGEM) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _alternarAcaoSeguir,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _estaSeguindo
                            ? Colors.white10
                            : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: _estaSeguindo
                              ? const BorderSide(color: Colors.white30)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        _estaSeguindo ? 'Seguindo' : 'Seguir',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatConversaView(
                              contacto: widget.usuario,
                              idUsuarioLogado: _meuId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text(
                        'Mensagem',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- GRID DE PUBLICAÇÕES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Publicações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _publicacoesUsuario.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'Nenhuma publicação enviada.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _publicacoesUsuario.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                              ),
                          itemBuilder: (context, index) {
                            // 🚀 Corrigido para usar a lista correta da classe
                            final post = _publicacoesUsuario[index];
                            final provider = _obterImageProvider(
                              post.imagemUrl,
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PublicacaoDetalheView(
                                      publicacao: post,
                                      // 🚀 Corrigido para usar os dados vindos de widget.usuario
                                      autorNome: widget.usuario.nome,
                                      autorFotoUrl: widget.usuario.fotoUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                  image: provider != null
                                      ? DecorationImage(
                                          image: provider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
