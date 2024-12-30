import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  bool _isMenuOpen = false;

  String? taller;
  bool isLoading = true;   
  bool showLoader = false;  
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && isLoading) {
        setState(() {
          showLoader = true;
        });
      }
    });

    _cargarTaller();
  }

  Future<void> _cargarTaller() async {
    try {
      final usuarioActivo = Supabase.instance.client.auth.currentUser;
      if (usuarioActivo == null) {
        setState(() {
          errorMessage = 'No hay usuario activo';
          isLoading = false;
          showLoader = false;
        });
        return;
      }

      final tallerObtenido =
          await ObtenerTaller().retornarTaller(usuarioActivo.id);

      setState(() {
        taller = tallerObtenido;
        isLoading = false;
        showLoader = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    if (isLoading && !showLoader) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: color.primary,
        title: const SizedBox(),
      
      );
    }

    if (isLoading && showLoader) {
      return AppBar(
        backgroundColor: color.primary,
        title: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return AppBar(
        title: Text('Error: $errorMessage'),
        backgroundColor: Colors.red,
      );
    }

    final size = MediaQuery.of(context).size;
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;

    final adminRoutes = [
  {'value': '/turnos/${taller ?? ''}', 'label': 'Clases'},
  {'value': '/misclases/${taller ?? ''}', 'label': 'Mis clases'},
  {'value': '/gestionhorarios/${taller ?? ''}', 'label': 'Gestión de horarios'},
  {'value': '/gestionclases/${taller ?? ''}', 'label': 'Gestión de clases'},
  {'value': '/usuarios/${taller ?? ''}', 'label': 'Alumnos/as'},
  {'value': '/configuracion/${taller ?? ''}', 'label': 'Configuración'},
  {'value': '/prueba', 'label': 'prueba'},
];
    final userRoutes = [
  {'value': '/turnos/${taller ?? ''}', 'label': 'Clases'},
  {'value': '/misclases/${taller ?? ''}', 'label': 'Mis clases'},
  {'value': '/configuracion/${taller ?? ''}', 'label': 'Configuración'},
];


    final menuItems = (userId == "dc326a14-214b-424c-845c-82396f2b73e3" ||
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
              context.push("/home/${taller ?? ''}");
            },
            child: 
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       'Taller de',
            //       style: TextStyle(
            //         fontSize: size.width * 0.05,
            //         fontWeight: FontWeight.bold,
            //         color: color.surface,
            //       ),
            //     ),
            //     Text(
            //       'Cerámica',
            //       style: TextStyle(
            //         fontSize: size.width * 0.05,
            //         fontWeight: FontWeight.bold,
            //         color: color.surface,
            //       ),
            //     ),
            //   ],
            // ),
            Text("$taller", style: const TextStyle(color: Colors.white),)
          ),
          SizedBox(width: size.width * 0.04),
          PopupMenuButton<String>(
            onSelected: (value) => context.push(value),
            itemBuilder: (BuildContext context) => menuItems
                .map((route) => PopupMenuItem(
                      value: route['value'] as String,
                      child: Text(route['label'] as String),
                    ))
                .toList(),
            icon: AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: color.surface,
              ),
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
                        context.push('/');
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
                          "dc326a14-214b-424c-845c-82396f2b73e3" ||
                      userId ==
                          "939d2e1a-13b3-4af0-be54-1a0205581f3b") ...[
                    SizedBox(
                      width: size.width * 0.23,
                      height: size.height * 0.044,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/crear-usuario/${taller ?? ''}');
                        },
                        child: Text(
                          'Crear',
                          style: TextStyle(fontSize: size.width * 0.032),
                        ),
                      ),
                    )
                  ],
                  SizedBox(width: size.width * 0.02),
                  SizedBox(
                    width: (userId ==
                                "dc326a14-214b-424c-845c-82396f2b73e3" ||
                            userId ==
                                "939d2e1a-13b3-4af0-be54-1a0205581f3b")
                        ? size.width * 0.23
                        : size.width * 0.34,
                    height: size.height * 0.044,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('session');

                        if (context.mounted) {
                          context.push('/');
                        }
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
      ],
    );
  }
}
