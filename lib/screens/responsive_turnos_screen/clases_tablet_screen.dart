// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/is_admin.dart';
import 'package:taller_ceramica/supabase/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/utils/generar_fechas_del_mes.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';

class ClasesTabletScreen extends StatefulWidget {
  const ClasesTabletScreen({super.key});

  @override
  State<ClasesTabletScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesTabletScreen> {
  List<String> fechasDisponibles = [];
  String semanaSeleccionada = 'semana1';
  String? diaSeleccionado;
  final List<String> semanas = [
    'semana1',
    'semana2',
    'semana3',
    'semana4',
    'semana5'
  ];
  int mesActual = 1;
  bool isLoading = true;

  List<ClaseModels> todasLasClases = [];
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);
    setState(() {
      isLoading = true;
    });

    final datos = await ObtenerTotalInfo(
      supabase: supabase,
      usuariosTable: 'usuarios',
      clasesTable: taller,
    ).obtenerClases();

    final datosSemana =
        datos.where((clase) => clase.semana == semanaSeleccionada).toList();

    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    datosSemana.sort((a, b) {
      String fechaA = '${a.fecha} ${a.hora}';
      String fechaB = '${b.fecha} ${b.hora}';

      DateTime parsedFechaA = dateFormat.parse(fechaA);
      DateTime parsedFechaB = dateFormat.parse(fechaB);

      return parsedFechaA.compareTo(parsedFechaB);
    });

    final diasSet = <String>{};
    diasUnicos = datosSemana.where((clase) {
      final diaFecha = '${clase.dia} - ${clase.fecha}';
      if (diasSet.contains(diaFecha)) {
        return false;
      } else {
        diasSet.add(diaFecha);
        return true;
      }
    }).toList();

    horariosPorDia = {};
    for (var clase in datosSemana) {
      final diaFecha = '${clase.dia} - ${clase.fecha}';
      horariosPorDia.putIfAbsent(diaFecha, () => []).add(clase);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void mostrarConfirmacion(BuildContext context, ClaseModels clase) async {
    final user = Supabase.instance.client.auth.currentUser;

    String mensaje;
    bool mostrarBotonAceptar = false;

    if (user == null) {
      mensaje = "Debes iniciar sesión para inscribirte a una clase";
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (clase.mails.contains(user.userMetadata?['fullname'])) {
      mensaje = 'Revisa en "mis clases"';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    final triggerAlert = await ObtenerAlertTrigger()
        .alertTrigger(user.userMetadata?['fullname']);
    final clasesDisponibles = await ObtenerClasesDisponibles()
        .clasesDisponibles(user.userMetadata?['fullname']);

    if (!context.mounted) return;

    if (triggerAlert > 0 && clasesDisponibles == 0) {
      mensaje =
          'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (clasesDisponibles == 0) {
      mensaje = "No tienes créditos disponibles para inscribirte a esta clase";
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }

    if (Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora, mesActual)) {
      mensaje = 'No puedes inscribirte a esta clase';
      if (context.mounted) {
        _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
      }
      return;
    }
    mensaje =
        '¿Deseas inscribirte a la clase el ${clase.dia} a las ${clase.hora}?';
    mostrarBotonAceptar = true;

    if (context.mounted) {
      _mostrarDialogo(context, mensaje, mostrarBotonAceptar, clase, user);
    }
  }

  void _mostrarDialogo(
      BuildContext context, String mensaje, bool mostrarBotonAceptar,
      [ClaseModels? clase, dynamic user]) {
    // Verificar si el widget sigue montado antes de usar el contexto
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _obtenerTituloDialogo(mensaje),
          ),
          content: Text(
            mensaje,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            if (mostrarBotonAceptar)
              ElevatedButton(
                onPressed: () {
                  if (clase != null && user != null) {
                    manejarSeleccionClase(
                        clase, user.userMetadata?['fullname'] ?? '');
                    ModificarAlertTrigger().resetearAlertTrigger(
                        user.userMetadata?['fullname'] ?? '');
                  }
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Aceptar'),
              ),
          ],
        );
      },
    );
  }

  String _obtenerTituloDialogo(String mensaje) {
    if (mensaje == "Debes iniciar sesión para inscribirte a una clase") {
      return "Inicia sesión";
    } else if (mensaje == 'Revisa en "mis clases"') {
      return "Ya estás inscrito en esta clase";
    } else if (mensaje ==
            "No tienes créditos disponibles para inscribirte a esta clase" ||
        mensaje ==
            'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación' ||
        mensaje == 'No puedes inscribirte a esta clase') {
      return "No puedes inscribirte a esta clase";
    } else {
      return "Confirmar Inscripción";
    }
  }

  void manejarSeleccionClase(ClaseModels clase, String user) async {
    await AgregarUsuario(supabase)
        .agregarUsuarioAClase(clase.id, user, false, clase);

    setState(() {
      cargarDatos();
    });
  }

  void cambiarSemanaAdelante() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual + 1) % semanas.length;
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos();
  }

  void cambiarSemanaAtras() {
    final indiceActual = semanas.indexOf(semanaSeleccionada);
    final nuevoIndice = (indiceActual - 1 + semanas.length) % semanas.length;
    semanaSeleccionada = semanas[nuevoIndice];
    cargarDatos();
  }

  void seleccionarDia(String dia) {
    setState(() {
      diaSeleccionado = dia;
    });
  }

  @override
  void initState() {
    super.initState();
    inicializarDatos();
    SubscriptionVerifier.verificarAdminYSuscripcion(context);
  }

  Future<void> inicializarDatos() async {
    try {
      final mes = await ObtenerMes().obtenerMes();
      setState(() {
        fechasDisponibles =
            GenerarFechasDelMes().generarFechasDelMes(mes, 2025);
        mesActual = mes;
      });

      await cargarDatos();
    } catch (e) {
      debugPrint('Error al inicializar los datos: $e');
    }
  }

  List<String> obtenerDiasConClasesDisponibles() {
    final diasConClases = <String>{};

    horariosPorDia.forEach((dia, clases) {
      if (clases.any((clase) =>
          clase.mails.length < 5 &&
          !Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora, mesActual) &&
          clase.lugaresDisponibles > 0)) {
        final partesFecha = dia.split(' - ')[1].split('/');
        final diaMes = int.parse(partesFecha[1]);
        if (diaMes == mesActual) {
          final diaSolo =
              dia.split(' - ')[0]; // Extraer solo el día (ej: "Lunes")
          diasConClases.add(diaSolo);
        }
      }
    });

    return diasConClases.toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Para inscribirte a una clase debes iniciar sesión!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    _SemanaNavigation(
                      semanaSeleccionada: semanaSeleccionada,
                      cambiarSemanaAdelante: cambiarSemanaAdelante,
                      cambiarSemanaAtras: cambiarSemanaAtras,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _DiaSelection(
                                    diasUnicos: diasUnicos,
                                    seleccionarDia: seleccionarDia,
                                    fechasDisponibles: fechasDisponibles,
                                    mesActual: mesActual,
                                  ),
                          ),
                          Expanded(
                            flex: 3,
                            child: diaSeleccionado != null
                                ? isLoading
                                    ? const SizedBox()
                                    : ListView.builder(
                                        itemCount:
                                            horariosPorDia[diaSeleccionado]
                                                    ?.length ??
                                                0,
                                        itemBuilder: (context, index) {
                                          final clase = horariosPorDia[
                                              diaSeleccionado]![index];
                                          return construirBotonHorario(clase);
                                        },
                                      )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Builder(
                        builder: (context) {
                          final diasConClases =
                              obtenerDiasConClasesDisponibles();
                          if (isLoading) {
                            return const SizedBox();
                          } else if (diasConClases.isEmpty) {
                            return _AvisoDeClasesDisponibles(
                              colors: colors,
                              color: color,
                              text: "No hay clases disponibles esta semana.",
                            );
                          } else {
                            return _AvisoDeClasesDisponibles(
                              colors: colors,
                              color: color,
                              text:
                                  "Hay clases disponibles el ${diasConClases.join(', ')}.",
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget construirBotonHorario(ClaseModels clase) {
    final partesFecha = clase.fecha.split('/');
    final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
    final diaYHora = '${clase.dia} $diaMes - ${clase.hora}';
    final estaLlena = clase.mails.length >= 5;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.15,
          height: screenWidth * 0.035,
          child: ElevatedButton(
            onPressed: ((estaLlena ||
                    Calcular24hs()
                        .esMenorA0Horas(clase.fecha, clase.hora, mesActual) ||
                    clase.lugaresDisponibles == 0))
                ? null
                : () async {
                    if (!await IsAdmin().admin()) {
                      mostrarConfirmacion(context, clase);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Los alumnos de esta clase son: ${clase.mails.join(', ')}",
                          ),
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                        ),
                      );
                    }
                  },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                estaLlena ||
                        Calcular24hs().esMenorA0Horas(
                            clase.fecha, clase.hora, mesActual) ||
                        clase.lugaresDisponibles == 0
                    ? Colors.grey.shade400
                    : Colors.green,
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05)),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  diaYHora,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _AvisoDeClasesDisponibles extends StatelessWidget {
  const _AvisoDeClasesDisponibles({
    required this.text,
    required this.colors,
    required this.color,
  });

  final ColorScheme colors;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.secondaryContainer,
            colors.primary.withAlpha(70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.02),
          Icon(
            Icons.info,
            color: color,
            size: screenWidth * 0.03,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.015,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemanaNavigation extends StatelessWidget {
  final String semanaSeleccionada;
  final VoidCallback cambiarSemanaAdelante;
  final VoidCallback cambiarSemanaAtras;

  const _SemanaNavigation({
    required this.semanaSeleccionada,
    required this.cambiarSemanaAdelante,
    required this.cambiarSemanaAtras,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.03, // 12% del ancho de la pantalla
            height: screenWidth * 0.03, // 12% del ancho para que sea circular
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: IconButton(
              onPressed: cambiarSemanaAtras,
              icon: const Icon(
                Icons.arrow_left,
              ),
              color: Colors.black,
            ),
          ),
          SizedBox(width: screenWidth * 0.06), // Espaciado entre los botones
          Container(
            width: screenWidth * 0.03,
            height: screenWidth * 0.03,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: IconButton(
              onPressed: cambiarSemanaAdelante,
              icon: const Icon(
                Icons.arrow_right,
              ),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para la selección de días

class _DiaSelection extends StatelessWidget {
  final List<ClaseModels> diasUnicos;
  final Function(String) seleccionarDia;
  final List<String> fechasDisponibles;
  final int mesActual;

  const _DiaSelection({
    required this.diasUnicos,
    required this.seleccionarDia,
    required this.fechasDisponibles,
    required this.mesActual,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.builder(
      itemCount: diasUnicos.length,
      itemBuilder: (context, index) {
        final clase = diasUnicos[index];

        // Procesar clase.fecha para mostrar solo día y mes
        final partesFecha = clase.fecha.split('/');
        final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
        final diaMesAnio = '${clase.dia} - ${clase.fecha}';

        final diaFecha = '${clase.dia} - $diaMes';

        // Filtrar fechasDisponibles para mostrar solo las fechas del mes actual
        final filteredFechas = fechasDisponibles.where((dateString) {
          final partes = dateString.split('/');
          final fecha = DateTime(
            int.parse(partes[2]), // Año
            int.parse(partes[1]), // Mes
            int.parse(partes[0]), // Día
          );

          // Compara solo el mes
          return fecha.month == mesActual;
        }).toList();

        // Si la fecha está en el mes actual, mostrar el botón
        if (filteredFechas.contains(clase.fecha)) {
          return Column(
            children: [
              SizedBox(
                width: screenWidth * 0.15, // 80% del ancho de la pantalla
                height: screenHeight * 0.075, // 6% del alto de la pantalla
                child: ElevatedButton(
                  onPressed: () => seleccionarDia(diaMesAnio),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.03), // 2% del ancho como radio
                    ),
                  ),
                  child: Text(
                    diaFecha,
                    style: TextStyle(
                        fontSize: screenWidth *
                            0.012), // 4% del ancho para el tamaño de fuente
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        } else {
          return const SizedBox
              .shrink(); // Si no está en el mes actual, no mostrar nada
        }
      },
    );
  }
}
