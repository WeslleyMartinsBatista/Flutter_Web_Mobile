enum TipoNotificacao { seguidor, publicacao }

class NotificacaoModel {
  final String id;
  final String idDestinatario; // ID do usuário que recebe a notificação
  final String idRemetente;    // ID do usuário que gerou a ação
  final String remetenteNome;
  final String? remetenteFotoUrl;
  final String titulo;
  final String mensagem;
  final TipoNotificacao tipo;
  final DateTime dataHora;

  NotificacaoModel({
    required this.id,
    required this.idDestinatario,
    required this.idRemetente,
    required this.remetenteNome,
    this.remetenteFotoUrl,
    required this.titulo,
    required this.mensagem,
    required this.tipo,
    required this.dataHora,
  });
}