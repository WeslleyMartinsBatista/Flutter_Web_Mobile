import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_mobile/model/UserModel.dart';
import '../database/MockDatabase.dart';

class LoginController {
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);

  Future<bool> fazerLogin(String email, String password) async {
    errorMessage.value = null;

    final emailTrimmed = email.trim().toLowerCase();

    if (emailTrimmed.isEmpty || password.isEmpty) {
      errorMessage.value = 'E-mail e senha são obrigatórios!';
      return false;
    }

    isLoading.value = true;

    try {
      // 1. Autentica e valida as credenciais via Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailTrimmed,
        password: password,
      );

      final String? uid = userCredential.user?.uid;

      if (uid != null) {
        // 2. Localiza ou instancia o UserModel com base no UID retornado do Firebase
        UserModel? usuarioEncontrado = MockDatabase.usuarios.firstWhereOrNull(
          (user) => user.id == uid || user.email.toLowerCase() == emailTrimmed,
        );

        // Se o usuário não existir no MockDatabase local, adiciona o perfil com o UID do Firebase
        if (usuarioEncontrado == null) {
          usuarioEncontrado = UserModel(
            id: uid,
            nome: userCredential.user?.displayName ?? emailTrimmed.split('@')[0],
            email: emailTrimmed,
            senha: '',
            mensagens: [],
          );
          MockDatabase.usuarios.add(usuarioEncontrado);
        } else {
          // Garante que o ID do MockDatabase está sincronizado com o UID real do Firebase
          usuarioEncontrado.id = uid;
        }

        currentUser.value = usuarioEncontrado;
        isLoading.value = false;
        return true;
      }

      errorMessage.value = 'Erro ao identificar o usuário autenticado.';
      isLoading.value = false;
      return false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      // Tratamento das mensagens de erro vindas do Firebase Auth
      if (e.code == 'user-not-found') {
        errorMessage.value = 'Nenhum usuário encontrado para este e-mail.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage.value = 'E-mail ou senha incorretos!';
      } else if (e.code == 'invalid-email') {
        errorMessage.value = 'Formato de e-mail inválido.';
      } else if (e.code == 'user-disabled') {
        errorMessage.value = 'Esta conta foi desativada.';
      } else {
        errorMessage.value = 'Erro ao realizar login: ${e.message}';
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Ocorreu um erro inesperado. Tente novamente.';
      return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    currentUser.dispose();
  }
}