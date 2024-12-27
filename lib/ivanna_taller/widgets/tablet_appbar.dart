import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';

class TabletAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const TabletAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight * 2.2);

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<TabletAppBar> {
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
            // {'value': '/prueba', 'label': 'prueba'},
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

          return Container(
            color: color.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push("/homeivanna");
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taller de Ceramica',
                        style: TextStyle(
                          fontSize: size.width * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Text(
                      //   'Cerámica',
                      //   style: TextStyle(
                      //     fontSize: size.width * 0.03,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(width: size.width * 0.02),
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
                        size: size.width * 0.02, color: color.surface),
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
                  offset: Offset(-size.width * 0.03, size.height * 0.10),
                ),
                const Spacer(),
                user == null
                    ? Row(
                        children: [
                          SizedBox(
                            height: size.width * 0.03,
                            width: size.width * 0.15,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/crear-usuarioivanna');
                              },
                              child: Text(
                                'Crear usuario',
                                style: TextStyle(fontSize: size.width * 0.015),
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          SizedBox(
                            height: size.width * 0.03,
                            width: size.width * 0.15,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/iniciar-sesionivanna');
                              },
                              child: Text(
                                'Iniciar sesión',
                                style: TextStyle(fontSize: size.width * 0.015),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: size.width * 0.03,
                        width: size.width * 0.15,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('session');
                            if (context.mounted) {
                              context.push('/homeivanna');
                            }
                            return;
                          },
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(fontSize: size.width * 0.015),
                          ),
                        ),
                      ),
              ],
            ),
          );
        });
  }
}
