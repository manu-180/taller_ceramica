import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(70.0);

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
        stream: Supabase.instance.client.auth.onAuthStateChange
            .map((event) => event.session?.user),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final userId = user?.id;

          final adminRoutes = [
            {'value': '/turnosivanna', 'label': 'Clases'},
            {'value': '/misclasesivanna', 'label': 'Mis clases'},
            {'value': '/gestionhorariosivanna', 'label': 'Gestión de horarios'},
            {'value': '/gestionclasesivanna', 'label': 'Gestión de clases'},
            {'value': '/usuariosivanna', 'label': 'Alumnos/as'},
            {'value': '/configuracionivanna', 'label': 'Configuración'},
            {'value': '/prueba', 'label': 'prueba'},
          ];

          final userRoutes = [
            {'value': '/turnosivanna', 'label': 'Clases'},
            {'value': '/misclasesivanna', 'label': 'Mis clases'},
            {'value': '/configuracionivanna', 'label': 'Configuración'},
          ];

          final menuItems = (userId == "e2446a58-b391-4f22-ab76-17648442acb6" ||
                  userId == "939d2e1a-13b3-4af0-be54-1a0205581f3b")
              ? adminRoutes
              : userRoutes;

          return AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: color.primary,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push("/homeivanna");
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taller de',
                          style: TextStyle(
                            fontSize: size.width * 0.05, // Tamaño relativo
                            fontWeight: FontWeight.bold,
                            color: color.surface,
                          ),
                        ),
                        Text(
                          'Cerámica',
                          style: TextStyle(
                            fontSize: size.width * 0.05, // Tamaño relativo
                            fontWeight: FontWeight.bold,
                            color: color.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      context.push(value);
                    },
                    itemBuilder: (BuildContext context) => menuItems
                        .map((route) => PopupMenuItem(
                              value: route['value'] as String,
                              child: Text(route['label'] as String),
                            ))
                        .toList(),
                    icon: AnimatedRotation(
                      turns: _isMenuOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_outlined,
                          color: color.surface),
                    ),
                    onOpened: () {
                      setState(() {
                        _isMenuOpen = true;
                      });
                    },
                    onCanceled: () {
                      setState(() {
                        _isMenuOpen = false;
                      });
                    },
                    offset: Offset(-size.width * 0.05, size.height * 0.07),
                  ),
                ],
              ),
              actions: [
                user == null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: size.width * 0.34,
                            height: size.height * 0.044,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/iniciar-sesionivanna');
                              },
                              child: Text(
                                'Iniciar',
                                style: TextStyle(fontSize: size.width * 0.034),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userId ==
                                  "e2446a58-b391-4f22-ab76-17648442acb6" ||
                              userId ==
                                  "939d2e1a-13b3-4af0-be54-1a0205581f3b") ...[
                            SizedBox(
                              width: size.width * 0.23,
                              height: size.height * 0.044,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.push('/crear-usuarioivanna');
                                },
                                child: Text(
                                  'Crear',
                                  style:
                                      TextStyle(fontSize: size.width * 0.032),
                                ),
                              ),
                            )
                          ],
                          SizedBox(width: size.width * 0.02),
                          SizedBox(
                            width: userId ==
                                        "e2446a58-b391-4f22-ab76-17648442acb6" ||
                                    userId ==
                                        "939d2e1a-13b3-4af0-be54-1a0205581f3b"
                                ? size.width * 0.23
                                : size.width * 0.34,
                            height: size.height * 0.044,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('session');
                                if (context.mounted) {
                                  context.push('/');
                                }
                                return;
                              },
                              child: Text(
                                'Cerrar',
                                style: TextStyle(fontSize: size.width * 0.032),
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(width: size.width * 0.032),
              ]);
        });
  }
}
