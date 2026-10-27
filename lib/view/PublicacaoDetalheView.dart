import 'package:flutter/foundation.dart'; // Necessário para usar kIsWeb
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/PublicacaoModel.dart';

class PublicacaoDetalheView extends StatelessWidget {
  final PublicacaoModel publicacao;
  final String autorNome;
  final String? autorFotoUrl;

  const PublicacaoDetalheView({
    super.key,
    required this.publicacao,
    required this.autorNome,
    this.autorFotoUrl,
  });

  ImageProvider? _obterImageProvider(String? caminhoOuUrl) {
    if (caminhoOuUrl == null || caminhoOuUrl.isEmpty) return null;

    // Se for HTTP, HTTPS ou um blob URL da web, usamos NetworkImage
    if (caminhoOuUrl.startsWith('http://') || 
        caminhoOuUrl.startsWith('https://') || 
        caminhoOuUrl.startsWith('blob:')) {
      return NetworkImage(caminhoOuUrl);
    } else {
      // Se estivermos na Web, caminhos locais diretos não usam FileImage
      if (kIsWeb) {
        return NetworkImage(caminhoOuUrl);
      } else {
        return FileImage(File(caminhoOuUrl));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagemProvider = _obterImageProvider(publicacao.imagemUrl);
    final avatarProvider = _obterImageProvider(autorFotoUrl);

    return Scaffold(
      backgroundColor: const Color(0xFF071835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent,
              backgroundImage: avatarProvider,
              child: avatarProvider == null
                  ? Text(
                      autorNome.isNotEmpty ? autorNome[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              autorNome,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // 🚀 Ícone no topo da imagem para abrir opções (salvar, reportar, etc.)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF0A2A55),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.bookmark_border, color: Colors.white),
                          title: const Text('Salvar publicação', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcionalidade de salvar em breve!')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.report_gmailerrorred, color: Colors.redAccent),
                          title: const Text('Reportar publicação', style: TextStyle(color: Colors.redAccent)),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Publicação reportada.')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEM DA PUBLICAÇÃO ---
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 450),
              color: Colors.black,
              child: imagemProvider != null
                  ? Image(
                      image: imagemProvider,
                      fit: BoxFit.contain,
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
                    ),
            ),

            const SizedBox(height: 12),

            // --- BOTÕES DE INTERAÇÃO (Curtir, Comentar, Republicar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // Sem ação por enquanto
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    onPressed: () {
                      // Sem ação por enquanto
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.white),
                    onPressed: () {
                      // Sem ação por enquanto
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // --- LEGENDA (Abaixo dos botões) ---
            if (publicacao.legenda != null && publicacao.legenda!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    children: [
                      TextSpan(
                        text: '$autorNome ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: publicacao.legenda!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}