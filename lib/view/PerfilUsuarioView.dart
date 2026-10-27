import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/PerfilUsuarioController.dart';
import '../model/PublicacaoModel.dart';
import '../model/UserModel.dart';
import 'PublicacaoDetalheView.dart';


class PerfilUsuarioView extends StatefulWidget {
  const PerfilUsuarioView({super.key});

  @override
  State<PerfilUsuarioView> createState() => _PerfilUsuarioViewState();
}

class _PerfilUsuarioViewState extends State<PerfilUsuarioView> {
  final PerfilUsuarioController _controller = PerfilUsuarioController();
  final ImagePicker _picker = ImagePicker();

  static const double _alturaBanner = 100.0;
  static const double _raioAvatar = 40.0;

  bool _modoEdicao = false;

  @override
  void initState() {
    super.initState();
    _controller.carregarPerfil();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- SELEÇÃO DE IMAGENS DO DISPOSITIVO ---

  Future<void> _selecionarImagemBanner() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final usuario = _controller.usuario.value;
        await _controller.salvarEdicaoPerfil(
          novoNome: usuario?.nome ?? '',
          novaBio: usuario?.bio ?? '',
          novaFotoUrl: usuario?.fotoUrl,
          novoBannerUrl: image.path, // Armazena o caminho local da imagem selecionada
        );
      }
    } catch (e) {
      _exibirMensagem('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _selecionarImagemPerfil() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final usuario = _controller.usuario.value;
        await _controller.salvarEdicaoPerfil(
          novoNome: usuario?.nome ?? '',
          novaBio: usuario?.bio ?? '',
          novaFotoUrl: image.path, // Armazena o caminho local da foto selecionada
          novoBannerUrl: usuario?.bannerUrl,
        );
      }
    } catch (e) {
      _exibirMensagem('Erro ao selecionar foto: $e');
    }
  }

  // --- EDIÇÃO DE TEXTO (NOME E BIO) ---

  void _editarNome(BuildContext context, String nomeAtual) {
    final textController = TextEditingController(text: nomeAtual);
    _exibirDialogoEdicao(
      context: context,
      titulo: 'Editar Nome de Usuário',
      labelField: 'Nome',
      controller: textController,
      onSalvar: () async {
        final usuario = _controller.usuario.value;
        await _controller.salvarEdicaoPerfil(
          novoNome: textController.text.trim(),
          novaBio: usuario?.bio ?? '',
          novaFotoUrl: usuario?.fotoUrl,
          novoBannerUrl: usuario?.bannerUrl,
        );
      },
    );
  }

  void _editarBio(BuildContext context, String bioAtual) {
    final textController = TextEditingController(text: bioAtual);
    _exibirDialogoEdicao(
      context: context,
      titulo: 'Editar Bio / Descrição',
      labelField: 'Bio',
      controller: textController,
      maxLines: 3,
      onSalvar: () async {
        final usuario = _controller.usuario.value;
        await _controller.salvarEdicaoPerfil(
          novoNome: usuario?.nome ?? '',
          novaBio: textController.text.trim(),
          novaFotoUrl: usuario?.fotoUrl,
          novoBannerUrl: usuario?.bannerUrl,
        );
      },
    );
  }

  // --- ADICIONAR PUBLICAÇÃO COM LEGENDA (SEM LOCALSTORAGESERVICE) ---
  Future<void> _adicionarNovaPublicacao(BuildContext context) async {
    try {
      final XFile? imagemPost = await _picker.pickImage(source: ImageSource.gallery);
      
      if (imagemPost != null && context.mounted) {
        // Abre diretamente o diálogo para o usuário digitar a legenda opcional
        final TextEditingController legendaController = TextEditingController();

        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A2A55),
              title: const Text('Adicionar Legenda', style: TextStyle(color: Colors.white, fontSize: 18)),
              content: TextField(
                controller: legendaController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Escreva uma legenda...',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    Navigator.pop(dialogContext); // Fecha o diálogo da legenda

                    // Envia diretamente o caminho do XFile para o Controller com a legenda
                    final sucesso = await _controller.adicionarPublicacao(
                      imagemPost.path,
                      legenda: legendaController.text.trim(),
                    );
                    
                    if (sucesso && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Publicação adicionada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Publicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar publicação: $e')),
        );
      }
    }
  }

  void _exibirDialogoEdicao({
    required BuildContext context,
    required String titulo,
    required String labelField,
    required TextEditingController controller,
    required Future<void> Function() onSalvar,
    int maxLines = 1,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A2A55),
          title: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelField,
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                await onSalvar();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _exibirMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // --- CARREGADOR UNIVERSAL DE IMAGEM (REDE E ARQUIVO LOCAL/WEB) ---

  ImageProvider? _obterImageProvider(String? caminhoOuUrl) {
    if (caminhoOuUrl == null || caminhoOuUrl.isEmpty) return null;

    if (caminhoOuUrl.startsWith('http://') || caminhoOuUrl.startsWith('https://')) {
      return NetworkImage(caminhoOuUrl);
    } else {
      // Para o suporte Web/Mobile com ImagePicker
      return NetworkImage(caminhoOuUrl); 
    }
  }

  // Widget para construir cada metrica individual
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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Divisor vertical sutil entre as métricas
  Widget _construirDivisorVertical() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.white24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071835),
      body: ValueListenableBuilder(
        valueListenable: _controller.usuario,
        builder: (context, usuario, child) {
          final nomeExibicao = usuario?.nome ?? 'Usuário';
          final emailExibicao = usuario?.email ?? '';
          final bioExibicao = usuario?.bio ?? 'Sem descrição cadastrada.';

          final bannerProvider = _obterImageProvider(usuario?.bannerUrl);
          final fotoProvider = _obterImageProvider(usuario?.fotoUrl);

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- BANNER + FOTO ---
                SizedBox(
                  height: _alturaBanner + _raioAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // BANNER
                      GestureDetector(
                        onTap: _modoEdicao ? _selecionarImagemBanner : null,
                        child: Container(
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
                          child: _modoEdicao
                              ? Container(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  child: const Center(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 18,
                                      child: Icon(Icons.photo_camera, size: 18, color: Colors.white),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),

                      // FOTO DE PERFIL
                      Positioned(
                        top: _alturaBanner - _raioAvatar,
                        child: GestureDetector(
                          onTap: _modoEdicao ? _selecionarImagemPerfil : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
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
                                          nomeExibicao.isNotEmpty ? nomeExibicao[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (_modoEdicao)
                                Container(
                                  height: _raioAvatar * 2,
                                  width: _raioAvatar * 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                  child: const Icon(Icons.photo_camera, color: Colors.white, size: 22),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // --- NOME ---
                GestureDetector(
                  onTap: _modoEdicao ? () => _editarNome(context, nomeExibicao) : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nomeExibicao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_modoEdicao) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, size: 16, color: Colors.blue),
                      ],
                    ],
                  ),
                ),

                Text(
                  emailExibicao,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 8),

                // --- BIO ---
                GestureDetector(
                  onTap: _modoEdicao ? () => _editarBio(context, bioExibicao) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            bioExibicao,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (_modoEdicao) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.edit, size: 16, color: Colors.blue),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Dentro da construção das métricas na PerfilUsuarioView.dart:
                ValueListenableBuilder<UserModel?>(
                  valueListenable: _controller.usuario,
                  builder: (context, usuarioLogado, child) {
                    final totalSeguidores = usuarioLogado?.seguidores.length ?? 0;
                    final totalSeguindo = usuarioLogado?.seguindo.length ?? 0;

                    return ValueListenableBuilder<List<PublicacaoModel>>(
                      valueListenable: _controller.publicacoes,
                      builder: (context, listaPosts, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _construirColunaMetrica('${listaPosts.length}', 'Publicações'),
                              _construirDivisorVertical(),
                              _construirColunaMetrica('$totalSeguidores', 'Seguidores'),
                              _construirDivisorVertical(),
                              _construirColunaMetrica('$totalSeguindo', 'Seguindo'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),

                // --- BOTÕES DE AÇÃO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      // Botão Editar / Concluir Edição
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _modoEdicao = !_modoEdicao;
                            });
                          },
                          icon: Icon(_modoEdicao ? Icons.check : Icons.edit, size: 16),
                          label: Text(
                            _modoEdicao ? 'Concluir Edição' : 'Editar Perfil',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _modoEdicao ? Colors.green : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Nova Publicação
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _adicionarNovaPublicacao(context); // Método para acionar a criação do post
                          },
                          icon: const Icon(Icons.add_box_outlined, size: 16),
                          label: const Text(
                            'Nova publicação',
                            style: TextStyle(fontSize: 13),
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

                // --- PUBLICAÇÕES ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minhas Publicações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- AQUI ENTRA O GRIDVIEW REATIVO COM AS PUBLICAÇÕES ---
                      ValueListenableBuilder<List<PublicacaoModel>>(
                        valueListenable: _controller.publicacoes,
                        builder: (context, listaPosts, child) {
                          if (listaPosts.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Text(
                                  'Nenhuma publicação ainda.',
                                  style: TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Evita conflito com o scroll da tela
                            itemCount: listaPosts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            // No item do GridView.builder na PerfilUsuarioView.dart:
                            itemBuilder: (context, index) {
                              final post = listaPosts[index];
                              final provider = _obterImageProvider(post.imagemUrl);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PublicacaoDetalheView(
                                        publicacao: post,
                                        autorNome: usuario?.nome ?? 'Usuário',
                                        autorFotoUrl: usuario?.fotoUrl,
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
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}