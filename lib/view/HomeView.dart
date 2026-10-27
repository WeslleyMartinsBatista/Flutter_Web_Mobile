import 'package:flutter/material.dart';
import 'package:flutter_web_mobile/view/ListaConversaView.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MenuSidebarView.dart'; // <-- Importe o novo menu
import 'PerfilUsuarioView.dart';
import 'PesquisaView.dart';
import 'NotificacaoView.dart';
import '../model/NotificacaoModel.dart';
import '../service/NotificacaoService.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  int _currentIndex = 0;

  // Lista com as telas da aplicação
  final List<Widget> _screens = [
    const Center(
      child: Text(
        'Feed / Linha do Tempo',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const PesquisaView(),
    const PerfilUsuarioView(),
  ];

  // Método para abrir o Menu Sidebar personalizado sobrepondo a tela
  void _abrirMenuSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.transparent, // Controlado internamente pela view
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MenuSidebarView(
          onSelecionarAba: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Efeito de deslizar da esquerda para a direita
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CORPO PRINCIPAL ---
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
              // --- AppBar Customizada ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Esquerda: Ícone do Menu Customizado
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => _abrirMenuSidebar(context), // Chama o menu deslizante
                      ),
                    ),
                    
                    // Centro: Título Centralizado
                    const Expanded(
                      child: Text(
                        'Rede TDS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Direita: Notificações e Chat
                    SizedBox(
                      width: 96,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Colors.white),
                            onPressed: () {
                              final uidAtual = FirebaseAuth.instance.currentUser?.uid ?? '';
                              
                              // Obtém estritamente as notificações geradas para o usuário logado
                              final notificacoesReais = NotificacaoService.obterNotificacoesDoUsuario(uidAtual);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificacaoView(
                                    notificacoes: notificacoesReais,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ListaConversaView(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- Conteúdo Principal Preservando Estados ---
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- BottomNavigationBar Customizada ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF071835),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Pesquisar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}