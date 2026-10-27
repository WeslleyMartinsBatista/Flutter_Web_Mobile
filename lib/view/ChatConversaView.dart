import 'package:flutter/material.dart';
import 'package:flutter_web_mobile/model/UserModel.dart';
import 'package:flutter_web_mobile/model/MessageModel.dart';
import 'package:flutter_web_mobile/service/ChatService.dart';

class ChatConversaView extends StatefulWidget {
  final UserModel contacto;
  final String idUsuarioLogado;

  const ChatConversaView({
    Key? key,
    required this.contacto,
    required this.idUsuarioLogado,
  }) : super(key: key);

  @override
  _ChatConversaViewState createState() => _ChatConversaViewState();
}

class _ChatConversaViewState extends State<ChatConversaView> {
  final ChatService _chatService = ChatService();
  final TextEditingController _mensagemController = TextEditingController();
  List<MessageModel> _mensagens = [];

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  void _carregarMensagens() {
    setState(() {
      _mensagens = _chatService.obterHistoricoConversa(
        widget.idUsuarioLogado,
        widget.contacto.id,
      );
    });
  }

  void _enviarMensagem() {
    if (_mensagemController.text.trim().isEmpty) return;

    _chatService.enviarMensagem(
      idRemetente: widget.idUsuarioLogado,
      idDestinatario: widget.contacto.id,
      texto: _mensagemController.text.trim(),
    );

    _mensagemController.clear();
    _carregarMensagens();

    // Fecha o teclado virtual após o envio
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF071835), Color(0xFF0A2A55)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Cabecalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Text(
                        widget.contacto.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.contacto.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de Mensagens
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _mensagens.length,
                  itemBuilder: (context, index) {
                    final mensagem = _mensagens[index];
                    final ehMinha = mensagem.idDestinatario == widget.contacto.id;

                    return Align(
                      alignment: ehMinha ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: ehMinha ? Colors.blue : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mensagem.text,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Campo de Entrada de Mensagem
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mensagemController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Digite uma mensagem...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _enviarMensagem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}