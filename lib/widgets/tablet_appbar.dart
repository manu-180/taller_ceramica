import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_supabase/obtener_taller.dart';

class TabletAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const TabletAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight * 2.2);

  @override
  TabletAppBarState createState() => TabletAppBarState();
}

class TabletAppBarState extends State<TabletAppBar> {
  bool _isMenuOpen = false;

  /// Variables para cargar el taller
  String? taller;
  bool isLoading = true;
  bool showLoader = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Pasado 1 segundo, si todavía está cargando, muestro loader
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
    final size = MediaQuery.of(context).size;

    // 1) Todavía no pasó 1s y seguimos cargando => AppBar vacío o con texto mínimo
    if (isLoading && !showLoader) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: color.primary,
        title: const Text(
          'Cargando...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // 2) Pasó 1s y todavía seguimos isLoading => AppBar con un CircularProgressIndicator
    if (isLoading && showLoader) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: color.primary,
        title: const Center(child: CircularProgressIndicator()),
      );
    }

    // 3) Si ocurrió algún error => AppBar con fondo rojo
    if (errorMessage != null) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: Text(
          'Error: $errorMessage',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    // 4) Ya tenemos el taller => construimos el AppBar “real”
    return StreamBuilder<User?>(
      stream: Supabase.instance.client.auth.onAuthStateChange
          .map((event) => event.session?.user),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userId = user?.id;

        // Rutas con el taller concatenado
        final adminRoutes = [
          {'value': '/turnos${taller ?? ''}', 'label': 'Clases'},
          {'value': '/misclases${taller ?? ''}', 'label': 'Mis clases'},
          {'value': '/gestionhorarios${taller ?? ''}', 'label': 'Gestión de horarios'},
          {'value': '/gestionclases${taller ?? ''}', 'label': 'Gestión de clases'},
          {'value': '/usuarios${taller ?? ''}', 'label': 'Alumnos/as'},
          {'value': '/configuracion${taller ?? ''}', 'label': 'Configuración'},
        ];

        final userRoutes = [
          {'value': '/turnos${taller ?? ''}', 'label': 'Clases'},
          {'value': '/misclases${taller ?? ''}', 'label': 'Mis clases'},
          {'value': '/configuracion${taller ?? ''}', 'label': 'Configuración'},
        ];

        final menuItems = (userId == "dc326a14-214b-424c-845c-82396f2b73e3" ||
                userId == "939d2e1a-13b3-4af0-be54-1a0205581f3b")
            ? adminRoutes
            : userRoutes;

        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: color.primary,
          toolbarHeight: widget.preferredSize.height,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push("/home${taller ?? ''}");
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taller de Cerámica ',
                      style: TextStyle(
                        fontSize: size.width * 0.02,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.02),
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
                    size: size.width * 0.02,
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
                offset: Offset(-size.width * 0.03, size.height * 0.10),
              ),
              const Spacer(),
              // Botones de login / logout
              user == null
                  ? Row(
                      children: [
                        SizedBox(
                          height: size.width * 0.03,
                          width: size.width * 0.15,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/crear-usuario${taller ?? ''}');
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
                              context.push('/iniciar-sesion${taller ?? ''}');
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
                            context.push('/home${taller ?? ''}');
                          }
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
      },
    );
  }
}
