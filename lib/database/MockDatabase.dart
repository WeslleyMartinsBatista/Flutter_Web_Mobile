import 'package:flutter_web_mobile/model/UserModel.dart';
import 'package:flutter_web_mobile/model/MessageModel.dart';

class MockDatabase {
  static List<UserModel> usuarios = [
    UserModel(
      id: "CRHvxlgd4pSrlpHefQQK7KSwZAH2", // UID do usuário do Firebase obtido após o cadastro/login
      nome: "Weslley",
      email: "2003weslleymb@gmail.com",
      senha: "", // senha gerenciada pelo Firebase Auth
      mensagens: [
        MessageModel(
          idDestinatario: "UID_DA_MARIA_FIREBASE", 
          text: "Olá Maria!", 
          hora: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
    UserModel(
      id: "EOywEZhMnyTCo1ZTeeWcqZbmH113",
      nome: "Maria",
      email: "maria@gmail.com",
      senha: "",
      mensagens: [
        MessageModel(
          idDestinatario: "UID_DO_WESLLEY_FIREBASE", 
          text: "Olá Weslley! Vi sim.", 
          hora: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
    ),
  ];
}