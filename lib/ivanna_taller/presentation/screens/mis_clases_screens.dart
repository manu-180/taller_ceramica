import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/functions_screens/box_text.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';

class MisClasesScreen extends ConsumerStatefulWidget {
  const MisClasesScreen({super.key});

  @override
  ConsumerState<MisClasesScreen> createState() => _MisClasesScreenState();
}

class _MisClasesScreenState extends ConsumerState<MisClasesScreen> {
  List<ClaseModels> clasesDelUsuario = [];

  void mostrarCancelacion(BuildContext context, ClaseModels clase) {
    final user = Supabase.instance.client.auth.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cancelación'),
          content: Text(
            Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)
                ? '¿Deseas cancelar la clase el ${clase.dia} a las ${clase.hora}?. ¡Se generará un credito para que puedas recuperarla!'
                : "¿Deseas cancelar la clase el ${clase.dia} a las ${clase.hora}? Ten en cuenta que si cancelas con menos de 24hs de anticipación no podrás recuperar la clase",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                cancelarClase(clase.id, user?.userMetadata?['fullname']);
                if (Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)) {
                  ModificarCredito()
                      .agregarCreditoUsuario(user?.userMetadata?['fullname']);
                } else {
                  ModificarAlertTrigger()
                      .agregarAlertTrigger(user?.userMetadata?['fullname']);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Cargar clases para el usuario actual
  Future<void> cargarClasesUsuario(String fullname) async {
    final datos = await ObtenerTotalInfo().obtenerInfo();
    clasesDelUsuario =
        datos.where((clase) => clase.mails.contains(fullname)).toList();
    clasesDelUsuario.sort((a, b) => a.id.compareTo(b.id));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider); // Estado inicial del usuario
    if (user != null) {
      cargarClasesUsuario(user.userMetadata?['fullname']);
    }
  }

  @override
Widget build(BuildContext context) {
  final user = ref.watch(authProvider); // Observa el estado del usuario
  final color = Theme.of(context).colorScheme;
  final size = MediaQuery.of(context).size;

  return Scaffold(
    appBar: ResponsiveAppBar(isTablet: size.width > 600),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: user == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      'Para ver tus clases debes iniciar sesión!',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: color.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: BoxText(
                        text:
                            "En esta sesión podrás ver y cancelar tus clases pero ¡cuidado! Si cancelas con menos de 24hs de anticipación no podrás recuperar la clase"),
                  ),
                  const SizedBox(height: 50),
                  clasesDelUsuario.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_busy,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 20),
                              Text(
                                'No estás inscripto en ninguna clase',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: color.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: clasesDelUsuario.length,
                            itemBuilder: (context, index) {
                              final clase = clasesDelUsuario[index];
                              final partesFecha = clase.fecha.split('/');
                              final diaMes =
                                  '${partesFecha[0]}/${partesFecha[1]}';
                              final diaMesAnio = '${clase.dia} $diaMes';
                              final claseInfo = '$diaMesAnio - ${clase.hora}';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      claseInfo,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        mostrarCancelacion(context, clase);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            166, 252, 93, 93),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: color.surface,
                                        ),
                                      ),
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
  );
}


  void cancelarClase(int claseId, String fullname) async {
    final clase = clasesDelUsuario.firstWhere((clase) => clase.id == claseId);
    clase.mails.remove(fullname);
    setState(() {
      clasesDelUsuario = clasesDelUsuario
          .where((clase) => clase.mails.contains(fullname))
          .toList();
    });
    await RemoverUsuario(Supabase.instance.client)
        .removerUsuarioDeClase(claseId, fullname, false);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Has cancelado tu inscripción en la clase'),
      ),
    );
  }
}
