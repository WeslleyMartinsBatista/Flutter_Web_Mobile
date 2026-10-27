import 'package:flutter_web_mobile/model/UserModel.dart';
import 'package:flutter_web_mobile/model/MessageModel.dart';
import 'package:flutter_web_mobile/database/MockDatabase.dart';

class ChatService {
  // Retorna a lista de usuários com quem o usuário logado possui conversas
  List<UserModel> obterConversasOrdenadas(String idUsuarioLogado) {
    final usuarioLogado = MockDatabase.usuarios.firstWhere((u) => u.id == idUsuarioLogado);
    final Map<String, DateTime> ultimaMensagemPorContacto = {};

    // Verifica mensagens enviadas pelo usuário logado
    for (var msg in usuarioLogado.mensagens) {
      final contactoId = msg.idDestinatario;
      if (!ultimaMensagemPorContacto.containsKey(contactoId) || msg.hora.isAfter(ultimaMensagemPorContacto[contactoId]!)) {
        ultimaMensagemPorContacto[contactoId] = msg.hora;
      }
    }

    // Verifica mensagens recebidas pelo usuário logado
    for (var outroUsuario in MockDatabase.usuarios) {
      if (outroUsuario.id == idUsuarioLogado) continue;
      for (var msg in outroUsuario.mensagens) {
        if (msg.idDestinatario == idUsuarioLogado) {
          final contactoId = outroUsuario.id;
          if (!ultimaMensagemPorContacto.containsKey(contactoId) || msg.hora.isAfter(ultimaMensagemPorContacto[contactoId]!)) {
            ultimaMensagemPorContacto[contactoId] = msg.hora;
          }
        }
      }
    }

    List<UserModel> contactosComConversa = MockDatabase.usuarios
        .where((u) => ultimaMensagemPorContacto.containsKey(u.id))
        .toList();

    contactosComConversa.sort((a, b) {
      return ultimaMensagemPorContacto[b.id]!.compareTo(ultimaMensagemPorContacto[a.id]!);
    });

    return contactosComConversa;
  }

  // Obtém o histórico completo entre dois usuários ordenado por horário
  List<MessageModel> obterHistoricoConversa(String idUsuarioLogado, String idContacto) {
    List<MessageModel> historico = [];

    final usuarioLogado = MockDatabase.usuarios.firstWhere(
      (u) => u.id == idUsuarioLogado,
      orElse: () => UserModel(id: '', nome: '', email: '', senha: '', mensagens: []),
    );

    final contacto = MockDatabase.usuarios.firstWhere(
      (u) => u.id == idContacto,
      orElse: () => UserModel(id: '', nome: '', email: '', senha: '', mensagens: []),
    );

    // Mensagens enviadas do usuário logado para o contato
    for (var msg in usuarioLogado.mensagens) {
      if (msg.idDestinatario == idContacto) {
        historico.add(msg);
      }
    }

    // Mensagens enviadas do contato para o usuário logado
    for (var msg in contacto.mensagens) {
      if (msg.idDestinatario == idUsuarioLogado) {
        historico.add(msg);
      }
    }

    // Ordena do horário mais antigo para o mais recente
    historico.sort((a, b) => a.hora.compareTo(b.hora));

    return historico;
  }

  // Envia e registra uma nova mensagem na lista do remetente
  void enviarMensagem({
    required String idRemetente,
    required String idDestinatario,
    required String texto,
  }) {
    final remetente = MockDatabase.usuarios.firstWhere(
      (u) => u.id == idRemetente,
    );

    final novaMensagem = MessageModel(
      idDestinatario: idDestinatario,
      text: texto,
      hora: DateTime.now(),
    );

    remetente.mensagens.add(novaMensagem);
  }
}