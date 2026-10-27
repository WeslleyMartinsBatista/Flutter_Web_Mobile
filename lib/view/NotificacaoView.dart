import 'package:flutter/material.dart';
import '../model/NotificacaoModel.dart';

class NotificacaoView extends StatelessWidget {
  final List<NotificacaoModel> notificacoes;

  const NotificacaoView({
    Key? key,
    required this.notificacoes,
  }) : super(key: key);

  ImageProvider? _obterImageProvider(String? caminhoOuUrl) {
    if (caminhoOuUrl == null || caminhoOuUrl.isEmpty) return null;
    return NetworkImage(caminhoOuUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: notificacoes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma notificação por enquanto.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: notificacoes.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final notif = notificacoes[index];
                final fotoProvider = _obterImageProvider(notif.remetenteFotoUrl);
                
                // Ícone indicativo do tipo de notificação
                final iconeTipo = notif.tipo == TipoNotificacao.seguidor
                    ? const Icon(Icons.person_add, color: Colors.blue, size: 16)
                    : const Icon(Icons.image, color: Colors.greenAccent, size: 16);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: fotoProvider,
                        child: fotoProvider == null
                            ? Text(
                                notif.remetenteNome.isNotEmpty
                                    ? notif.remetenteNome[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFF071835),
                        child: iconeTipo,
                      ),
                    ],
                  ),
                  title: Text(
                    notif.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        notif.mensagem,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Ação ao clicar na notificação (opcional)
                  },
                );
              },
            ),
    );
  }
}