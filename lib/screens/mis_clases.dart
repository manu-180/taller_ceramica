import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/utils/utils_barril.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';

class MisClasesScreen extends ConsumerStatefulWidget {
  const MisClasesScreen({super.key, String? taller});

  @override
  ConsumerState<MisClasesScreen> createState() => MisClasesScreenState();
}

class MisClasesScreenState extends ConsumerState<MisClasesScreen> {
  List<ClaseModels> clasesDelUsuario = [];
  List<ClaseModels> listaDeEsperaDelUsuario = [];
  int mesActual = 1;

  @override
  void initState() {
    super.initState();
    SubscriptionVerifier.verificarAdminYSuscripcion(context);
    cargarMesActual();
    final user = ref.read(authProvider);
    if (user != null) {
      cargarClasesOrdenadasPorProximidad(user.userMetadata?['fullname']);
    }
  }

  void mostrarCancelacion(BuildContext context, ClaseModels clase,  bool esListaDeEspera) {
  final user = Supabase.instance.client.auth.currentUser;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: Text(
          esListaDeEspera
              ? '¿Deseas cancelar tu lugar en la lista de espera para la clase del ${clase.dia} a las ${clase.hora}?'
              : Calcular24hs().esMayorA24Horas(clase.fecha, clase.hora)
                  ? '¿Deseas cancelar la clase el ${clase.dia} a las ${clase.hora}? ¡Se generará un crédito para que puedas recuperarla!'
                  : "¿Deseas cancelar la clase el ${clase.dia} a las ${clase.hora}? Ten en cuenta que si cancelas con menos de 24hs de anticipación no podrás recuperar la clase",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (esListaDeEspera) {
                cancelarClaseEnListaDeEspera(clase.id, user?.userMetadata?['fullname']);
              } else {
                cancelarClase(clase.id, user?.userMetadata?['fullname']);
                
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


  void cancelarClase(int claseId, String fullname) async {
    final clase = clasesDelUsuario.firstWhere((clase) => clase.id == claseId);
    clase.mails.remove(fullname);
    setState(() {
      clasesDelUsuario = clasesDelUsuario
          .where((clase) => clase.mails.contains(fullname))
          .toList();
    });
    await RemoverUsuario(supabase)
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

  void cancelarClaseEnListaDeEspera(int claseId, String fullname) async {
    final clase = listaDeEsperaDelUsuario.firstWhere((clase) => clase.id == claseId);
    clase.espera.remove(fullname);
    setState(() {
      listaDeEsperaDelUsuario = listaDeEsperaDelUsuario
          .where((clase) => clase.espera.contains(fullname))
          .toList();
    });
    await RemoverUsuario(supabase)
        .removerUsuarioDeListaDeEspera(claseId, fullname);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Has cancelado tu clase en lista de espera'),
      ),
    );
  }

  Future<void> cargarMesActual() async {
    try {
      final int mes = await ObtenerMes().obtenerMes();
      if (mounted) {
        setState(() {
          mesActual = mes;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener el mes actual: $e');
    }
  }

  Future<void> cargarClasesOrdenadasPorProximidad(String fullname) async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    final datos = await ObtenerTotalInfo(
      supabase: supabase,
      usuariosTable: 'usuarios',
      clasesTable: taller,
    ).obtenerClases();

    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    final clasesUsuario = datos.where((clase) {
      return clase.mails.contains(fullname);
    }).toList();

    clasesUsuario.sort((a, b) {
      final fechaHoraA = '${a.fecha} ${a.hora}';
      final fechaHoraB = '${b.fecha} ${b.hora}';

      final dateTimeA = dateFormat.parse(fechaHoraA);
      final dateTimeB = dateFormat.parse(fechaHoraB);

      final ahora = DateTime.now();
      final diffA = dateTimeA.difference(ahora).inMilliseconds;
      final diffB = dateTimeB.difference(ahora).inMilliseconds;

      return diffA.compareTo(diffB);
    });

    final listaEspera = datos.where((clase) {
      return clase.espera.contains(fullname);
    }).toList();

    clasesUsuario.sort((a, b) {
      final fechaHoraA = '${a.fecha} ${a.hora}';
      final fechaHoraB = '${b.fecha} ${b.hora}';

      final dateTimeA = dateFormat.parse(fechaHoraA);
      final dateTimeB = dateFormat.parse(fechaHoraB);

      final ahora = DateTime.now();
      final diffA = dateTimeA.difference(ahora).inMilliseconds;
      final diffB = dateTimeB.difference(ahora).inMilliseconds;

      return diffA.compareTo(diffB);
    });

    listaDeEsperaDelUsuario = listaEspera.cast<ClaseModels>();
    clasesDelUsuario = clasesUsuario.cast<ClaseModels>();

    if (mounted) setState(() {});
  }

  @override
Widget build(BuildContext context) {
  final user = ref.watch(authProvider);
  final color = Theme.of(context).colorScheme;

  return Scaffold(
    appBar: ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
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
                          "En esta sesión podrás ver y cancelar tus clases pero ¡cuidado! Si cancelas con menos de 24hs de anticipación no podrás recuperar la clase",
                    ),
                  ),
                  const SizedBox(height: 50),
                  (clasesDelUsuario.isEmpty && listaDeEsperaDelUsuario.isEmpty)
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
                          child: Column(
                            children: [
                              Expanded(
                                flex: listaDeEsperaDelUsuario.isEmpty ? 8 : 5,
                                child: ListView.builder(
                                  itemCount: clasesDelUsuario.length,
                                  itemBuilder: (context, index) {
                                    final clase = clasesDelUsuario[index];
                                    final partesFecha = clase.fecha.split('/');
                                    final diaMes =
                                        '${partesFecha[0]}/${partesFecha[1]}';
                                    final diaMesAnio = '${clase.dia} $diaMes';
                                    final claseInfo =
                                        '$diaMesAnio - ${clase.hora}';

                                    final bool claseYaPaso = Calcular24hs()
                                        .esMenorA0Horas(clase.fecha,
                                            clase.hora, mesActual);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      child: Opacity(
                                        opacity: claseYaPaso ? 0.5 : 1.0,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              claseInfo,
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            ),
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                mostrarCancelacion(
                                                    context, clase,false);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        166, 252, 93, 93),
                                              ),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (listaDeEsperaDelUsuario.isNotEmpty)
                                Expanded(
                                  flex: 3,
                                  child: ListView.builder(
                                    itemCount:
                                        listaDeEsperaDelUsuario.length,
                                    itemBuilder: (context, index) {
                                      final clase =
                                          listaDeEsperaDelUsuario[index];
                                      final partesFecha =
                                          clase.fecha.split('/');
                                      final diaMes =
                                          '${partesFecha[0]}/${partesFecha[1]}';
                                      final diaMesAnio =
                                          '${clase.dia} $diaMes';
                                      final claseInfo =
                                          '$diaMesAnio - ${clase.hora}';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        child: Card(
                                          elevation: 4,
                                          color: const Color(0xFFE3F2FD),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              claseInfo,
                                              style: const TextStyle(
                                                color:Colors.blue,
                                                  fontSize: 14),
                                            ),
                                            subtitle: Text("Tu lugar en espera: ${clase.espera.indexOf(user.userMetadata?['fullname']) + 1}", style: const TextStyle(
                                                color:Colors.blue,
                                                  fontSize: 11),),
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                mostrarCancelacion(
                                                    context, clase, true);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:Color(
                                                            0xFF4FC3F7)
                                              ),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
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
                ],
              ),
      ),
    ),
  );
}

}
