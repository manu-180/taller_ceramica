import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/models/clase_models.dart';

import '../../../../funciones_globales/utils/utils_barril.dart';
import '../../../../ivanna_taller/supabase/supabase_barril.dart';

class ClasesScreenManu extends StatefulWidget {
  const ClasesScreenManu({super.key});

  @override
  State<ClasesScreenManu> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreenManu> {
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
  bool isLoading = true;

  List<ClaseModels> todasLasClases = [];
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};

  Future<void> cargarDatos() async {
    setState(() {
      isLoading = true; // Indicamos que se está cargando
    });

    final datos = await ObtenerTotalInfoManu().obtenerClaseManu();

    // Filtramos las clases por la semana seleccionada
    final datosSemana =
        datos.where((clase) => clase.semana == semanaSeleccionada).toList();

    // Crea un objeto DateFormat para el formato "dd/MM/yyyy HH:mm"
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    // Ordenamos primero por la fecha (ascendente) y luego por la hora (ascendente)
    datosSemana.sort((a, b) {
      // Concatenamos la hora al dato de fecha ya existente
      String fechaA = '${a.fecha} ${a.hora}';
      String fechaB = '${b.fecha} ${b.hora}';

      // Convierte las fechas y horas a DateTime usando DateFormat
      DateTime parsedFechaA = dateFormat.parse(fechaA);
      DateTime parsedFechaB = dateFormat.parse(fechaB);

      return parsedFechaA.compareTo(parsedFechaB);
    });

    // Extraemos días únicos basados en la fecha y día
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
        isLoading = false; // Desactivamos el indicador de carga
      });
    }
  }

  void mostrarConfirmacion(BuildContext context, ClaseModels clase) async {
    final user = Supabase.instance.client.auth.currentUser;

    // Inicializar variables para el mensaje y el botón
    String mensaje;
    bool mostrarBotonAceptar = false;

    // Verificar si el usuario está autenticado
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

    // Operaciones asincrónicas
    final triggerAlert = await ObtenerAlertTriggerManu()
        .alertTriggerManu(user.userMetadata?['fullname']);
    final clasesDisponibles = await ObtenerClasesDisponiblesManu()
        .clasesDisponiblesManu(user.userMetadata?['fullname']);

    if (!context.mounted) return; // Verificar si el widget sigue montado

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

    if (Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora)) {
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
    await AgregarUsuarioManu(supabase)
        .agregarUsuarioAClaseManu(clase.id, user, false, clase);

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
    fechasDisponibles = GenerarFechasDelMes().generarFechasLunesAViernes();
    cargarDatos();
  }

  List<String> obtenerDiasConClasesDisponibles() {
    final diasConClases = <String>{};
    final currentMonth = DateTime.now().month;

    horariosPorDia.forEach((dia, clases) {
      if (clases.any((clase) =>
          clase.mails.length < 5 &&
          !Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora) &&
          clase.lugaresDisponibles > 0)) {
        final partesFecha = dia.split(' - ')[1].split('/');
        final diaMes = int.parse(partesFecha[1]);
        if (diaMes == currentMonth) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;

    // Relativo a la pantalla
    double paddingSize = screenWidth * 0.05; // 5% del ancho de la pantalla
    double buttonWidth = screenWidth * 0.7; // 70% del ancho de la pantalla
    double fontSize = screenWidth * 0.04; // 4% del ancho de la pantalla

    return Scaffold(
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(paddingSize, 20, paddingSize, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "En esta sesión podrás ver los horarios disponibles para las clases de cerámica. ¡Reserva tu lugar ahora!",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: fontSize),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _SemanaNavigation(
            semanaSeleccionada: semanaSeleccionada,
            cambiarSemanaAdelante: cambiarSemanaAdelante,
            cambiarSemanaAtras: cambiarSemanaAtras,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: isLoading
                      ? Column(
                          children: List.generate(
                              5,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: SizedBox(
                                      height: buttonWidth * 0.166,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                        )
                      : _DiaSelection(
                          diasUnicos: diasUnicos,
                          seleccionarDia: seleccionarDia,
                          fechasDisponibles: fechasDisponibles,
                        ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: paddingSize * 2, right: paddingSize),
                    child: diaSeleccionado != null
                        ? isLoading
                            ? const SizedBox()
                            : ListView.builder(
                                itemCount:
                                    horariosPorDia[diaSeleccionado]?.length ??
                                        0,
                                itemBuilder: (context, index) {
                                  final clase =
                                      horariosPorDia[diaSeleccionado]![index];
                                  return construirBotonHorario(clase);
                                },
                              )
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: paddingSize, vertical: 20),
            child: Builder(
              builder: (context) {
                final diasConClases = obtenerDiasConClasesDisponibles();
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
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget construirBotonHorario(ClaseModels clase) {
    final partesFecha = clase.fecha.split('/');
    final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
    final diaYHora = '${clase.dia} $diaMes - ${clase.hora}';
    final estaLlena = clase.mails.length >= 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Supabase.instance.client.auth.currentUser;

    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.7,
          height: screenWidth * 0.12,
          child: ElevatedButton(
            onPressed: ((estaLlena ||
                        Calcular24hs()
                            .esMenorA0Horas(clase.fecha, clase.hora) ||
                        clase.lugaresDisponibles == 0) &&
                    user?.id != "939d2e1a-13b3-4af0-be54-1a0205581f3b")
                ? null
                : () {
                    if (user?.id != "939d2e1a-13b3-4af0-be54-1a0205581f3b") {
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
                        Calcular24hs()
                            .esMenorA0Horas(clase.fecha, clase.hora) ||
                        clase.lugaresDisponibles == 0
                    ? Colors.grey.shade400
                    : Colors.green,
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03)),
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
    // Obtener dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.secondaryContainer,
            colors.primary.withAlpha(70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
            screenWidth * 0.03), // 3% del ancho para el borde redondeado
        boxShadow: [
          BoxShadow(
            color: colors.primary.withAlpha(70),
            spreadRadius:
                screenWidth * 0.005, // 0.5% del ancho para spreadRadius
            blurRadius: screenWidth * 0.01, // 1% del ancho para blurRadius
            offset:
                Offset(0, screenHeight * 0.005), // 0.5% del alto para offset
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: color,
            size: screenWidth * 0.08, // 8% del ancho para el tamaño del ícono
          ),
          SizedBox(width: screenWidth * 0.03), // 3% del ancho para el espaciado
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize:
                    screenWidth * 0.04, // 4% del ancho para el tamaño de fuente
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
        horizontal:
            screenWidth * 0.04, // 4% del ancho para el padding horizontal
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.12, // 12% del ancho de la pantalla
            height: screenWidth * 0.12, // 12% del ancho para que sea circular
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: screenWidth * 0.01, // 1% del ancho para el blur
                  offset: Offset(
                      0, screenHeight * 0.005), // 0.5% del alto para el offset
                ),
              ],
            ),
            child: IconButton(
              onPressed: cambiarSemanaAtras,
              icon: Icon(
                Icons.arrow_left,
                size:
                    screenWidth * 0.07, // 7% del ancho para el tamaño del ícono
              ),
              color: Colors.black,
            ),
          ),
          SizedBox(width: screenWidth * 0.12), // Espaciado entre los botones
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: screenWidth * 0.01,
                  offset: Offset(0, screenHeight * 0.005),
                ),
              ],
            ),
            child: IconButton(
              onPressed: cambiarSemanaAdelante,
              icon: Icon(
                Icons.arrow_right,
                size: screenWidth * 0.07,
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

  const _DiaSelection({
    required this.diasUnicos,
    required this.seleccionarDia,
    required this.fechasDisponibles,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;

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
          return fecha.month == currentMonth;
        }).toList();

        // Si la fecha está en el mes actual, mostrar el botón
        if (filteredFechas.contains(clase.fecha)) {
          return Column(
            children: [
              SizedBox(
                width: screenWidth * 0.8, // 80% del ancho de la pantalla
                height: screenHeight * 0.053, // 6% del alto de la pantalla
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
                            0.033), // 4% del ancho para el tamaño de fuente
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
