class MessageModel {
  final String idDestinatario;
  String text;
  DateTime hora;

  MessageModel({
    required this.idDestinatario,
    required this.text,
    required this.hora,
  });
}