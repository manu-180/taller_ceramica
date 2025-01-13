// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/usuario_models.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';

import '../utils/utils_barril.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key, String? taller});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  bool isLoading = true;
  List<UsuarioModels> usuarios = [];

  Future<void> cargarUsuarios() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    setState(() {
      isLoading = true;
    });

    final datos = await ObtenerTotalInfo(
      supabase: supabase,
      usuariosTable: 'usuarios',
      clasesTable: taller,
    ).obtenerUsuarios();
    if (mounted) {
      setState(() {
        usuarios = List<UsuarioModels>.from(
          datos.where((usuario) => usuario.taller == taller),
        );
        // Ordenar usuarios alfabéticamente por el nombre completo (fullname)
        usuarios.sort((a, b) => a.fullname.compareTo(b.fullname));
        isLoading = false;
      });
    }
  }

  Future<void> eliminarUsuario(int userId, String userUid) async {
    await EliminarUsuario().eliminarDeBaseDatos(userId);
    await EliminarDeBD().deleteCurrentUser(userUid);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado exitosamente')),
    );
    await cargarUsuarios();
  }

  Future<void> agregarCredito(String user) async {
    final resultado = await ModificarCredito().agregarCreditoUsuario(user);
    if (resultado) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédito agregado exitosamente')),
      );
      await cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar el crédito')),
      );
    }
  }

  Future<void> removerCredito(String user) async {
    final resultado = await ModificarCredito().removerCreditoUsuario(user);
    if (resultado) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédito removido exitosamente')),
      );
      await cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al remover el crédito')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    SubscriptionVerifier.verificarAdminYSuscripcion(context);
    cargarUsuarios();
  }

  Future<void> mostrarDialogoEliminar({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required VoidCallback onConfirmar,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      onConfirmar();
    }
  }

  Future<void> mostrarDialogoConContador({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required Function(int cantidad)
        onConfirmar, // Recibe la cantidad de créditos
  }) async {
    int contador = 1; // Comienza con 1 crédito

    final resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Para actualizar el estado del contador
          builder: (context, setState) {
            return AlertDialog(
              title: Text(titulo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(contenido),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.orange),
                        onPressed: () {
                          if (contador > 1) {
                            setState(() {
                              contador--;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$contador',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            contador++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true) {
      onConfirmar(contador);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar:
          ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: BoxText(
                          text:
                              "En esta sección podrás ver los usuarios registrados y modificar sus créditos, también eliminarlos si es necesario"),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: usuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = usuarios[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Card(
                              surfaceTintColor:
                                  usuario.admin ? Colors.amber : Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text('${usuario.fullname} '),
                                subtitle: Text(usuario.clasesDisponibles == 1
                                    ? "(${usuario.clasesDisponibles} crédito)"
                                    : "(${usuario.clasesDisponibles} créditos)"),
                                onTap: () async {
                                  final lista = await AlumnosEnClase()
                                      .clasesAlumno(usuario.fullname, "mails");
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        lista.isEmpty
                                            ? "${usuario.fullname} no tiene clases programadas"
                                            : "${usuario.fullname} asiste a las clases: ${lista.join(', ')}",
                                      ),
                                      duration: const Duration(seconds: 8),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(10),
                                    ),
                                  );
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => mostrarDialogoEliminar(
                                        context: context,
                                        titulo: 'Eliminar Usuario',
                                        contenido:
                                            '¿Estás seguro de que deseas eliminar a este usuario?',
                                        onConfirmar: () => eliminarUsuario(
                                            usuario.id, usuario.userUid),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.green),
                                      onPressed: () =>
                                          mostrarDialogoConContador(
                                        context: context,
                                        titulo: 'Agregar Créditos',
                                        contenido:
                                            'Selecciona cuántos créditos quieres agregar:',
                                        onConfirmar: (cantidad) async {
                                          for (int i = 0; i < cantidad; i++) {
                                            await agregarCredito(
                                                usuario.fullname);
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove,
                                          color: Colors.orange),
                                      onPressed: () =>
                                          mostrarDialogoConContador(
                                        context: context,
                                        titulo: 'Remover Créditos',
                                        contenido:
                                            'Selecciona cuántos créditos quieres remover:',
                                        onConfirmar: (cantidad) async {
                                          for (int i = 0; i < cantidad; i++) {
                                            await removerCredito(
                                                usuario.fullname);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: SizedBox(
        width: size.width * 0.38,
        child: FloatingActionButton(
          onPressed: () async {
            final usuarioActivo = Supabase.instance.client.auth.currentUser;
            final taller =
                await ObtenerTaller().retornarTaller(usuarioActivo!.id);

            context.push('/crear-usuario/$taller');
          },
          child: Text(
            'Crear nuevo usaurio',
            style: TextStyle(fontSize: size.width * 0.032),
          ),
        ),
      ),
    );
  }
}
