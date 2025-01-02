import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/is_admin.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';

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
  bool isAdmin = false;

  

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
    _checkAdminStatus();
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

  Future<void> _checkAdminStatus() async {
    try {
      final adminStatus = await IsAdmin().admin();
      setState(() {
        isAdmin = adminStatus;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al verificar el estado de administrador';
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
        backgroundColor: color.primary,
      );
    }

    final size = MediaQuery.of(context).size;
    final user = Supabase.instance.client.auth.currentUser;

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


    final menuItems = (isAdmin)
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: color.surface,
                  ),
                ),
                Text(
                  'Cerámica',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: color.surface,
                  ),
                ),
              ],
            ),
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
                  if (isAdmin) ...[
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
                    width: (isAdmin)
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
