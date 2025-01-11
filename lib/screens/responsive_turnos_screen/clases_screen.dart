import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/obtener_datos/is_admin.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_capacidad_clase.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_datos/obtener_taller.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/utils/generar_fechas_del_mes.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';
import 'package:taller_ceramica/widgets/shimmer_loader.dart';

class ClasesScreen extends StatefulWidget {
  const ClasesScreen({
    super.key,
  });

  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
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
  List<ClaseModels> diasUnicos = [];
  Map<String, List<ClaseModels>> horariosPorDia = {};
  String? avisoDeClasesDisponibles;
  Map<int, int> capacidadCache = {};

  Future<void> cargarDatos() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    setState(() {
      isLoading = true;
    });

    final capacidades = await ObtenerCapacidadClase().cargarTodasLasCapacidades();
    for (var capacidad in capacidades) {
      capacidadCache[capacidad['id']] = capacidad['capacidad'];
    }

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

    final diasConClasesDisponibles = await obtenerDiasConClasesDisponibles();
if (diasConClasesDisponibles.isEmpty) {
  avisoDeClasesDisponibles = "No hay clases disponibles esta semana.";
} else {
  avisoDeClasesDisponibles =
      "Hay clases disponibles el ${diasConClasesDisponibles.join(', ')}.";
}

if (mounted) {
  setState(() {
    isLoading = false;
  });
}

  }

  Future<List<String>> obtenerDiasConClasesDisponibles() async {
  final diasConClases = <String>{};

  for (var entry in horariosPorDia.entries) {
    final dia = entry.key;
    final clases = entry.value;

    for (var clase in clases) {
      // Consultar la capacidad desde la caché
      final capacidad = capacidadCache[clase.id] ?? 0;

      final mailsLimpios = clase.mails.map((mail) => mail.trim()).toList();
      final menorA24 = Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora, mesActual);


      if (mailsLimpios.length < capacidad && !menorA24) {
        final partesFecha = dia.split(' - ')[1].split('/');
        final diaMes = int.parse(partesFecha[1]);

        if (diaMes == mesActual) {
          final diaSolo = dia.split(' - ')[0]; // Extraer solo el día (ej: "Lunes")
          diasConClases.add(diaSolo);
        }
      }
    }
  }

  return diasConClases.toList();
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

  void cambiarSemanaAdelante() {
  final indiceActual = semanas.indexOf(semanaSeleccionada);
  final nuevoIndice = (indiceActual + 1) % semanas.length;

  setState(() {
    semanaSeleccionada = semanas[nuevoIndice];
    isLoading = true;
    avisoDeClasesDisponibles = null;
  });

  cargarDatos();
}

void cambiarSemanaAtras() {
  final indiceActual = semanas.indexOf(semanaSeleccionada);
  final nuevoIndice = (indiceActual - 1 + semanas.length) % semanas.length;

  setState(() {
    semanaSeleccionada = semanas[nuevoIndice];
    isLoading = true;
    avisoDeClasesDisponibles = null;
  });

  cargarDatos();
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

  final mailsLimpios = clase.mails.map((mail) => mail.trim()).toList();

  if (mailsLimpios.contains(user.userMetadata?['fullname'])) {
    mensaje = 'Revisa en "mis clases"';
    if (context.mounted) {
      _mostrarDialogo(context, mensaje, mostrarBotonAceptar);
    }
    return;
  }

  final triggerAlert = await ObtenerAlertTrigger().alertTrigger(user.userMetadata?['fullname']);
  final clasesDisponibles = await ObtenerClasesDisponibles().clasesDisponibles(user.userMetadata?['fullname']);

  if (!context.mounted) return;

  if (triggerAlert > 0 && clasesDisponibles == 0) {
    mensaje = 'No puedes recuperar una clase si cancelaste con menos de 24hs de anticipación';
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

  mensaje = '¿Deseas inscribirte a la clase el ${clase.dia} a las ${clase.hora}?';
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

  void manejarSeleccionClase(ClaseModels clase, String user) async {
    await AgregarUsuario(supabase)
        .agregarUsuarioAClase(clase.id, user, false, clase);

    setState(() {
      cargarDatos();
    });
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

  void seleccionarDia(String dia) {
    setState(() {
      diaSeleccionado = dia;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Relativo a la pantalla
    double paddingSize = screenWidth * 0.05; // 5% del ancho de la pantalla

    return Scaffold(
      appBar: ResponsiveAppBar(isTablet: screenWidth > 600),
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
                    ?.copyWith(fontSize: screenWidth * 0.04),
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
                                      height: screenWidth * 0.113,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 2.2,)),
                                        ),
                                      ),
                                    ),
                                  )),
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingSize),
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
                                  return FutureBuilder<Widget>(
                                    future: construirBotonHorario(clase, capacidadCache),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator(strokeWidth: 2.2,);
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return snapshot.data ??
                                            const SizedBox();
                                      }
                                    },
                                  );
                                },
                              )
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
  padding: EdgeInsets.symmetric(horizontal: paddingSize, vertical: 20),
  child: avisoDeClasesDisponibles != null && !isLoading
      ? _AvisoDeClasesDisponibles(
          colors: colors,
          color: color,
          text: avisoDeClasesDisponibles!,
        )
      : ShimmerLoading(
          brillo: colors.primary.withAlpha(40),
          color: colors.primary.withAlpha(120),
          height: screenWidth * 0.19,
          width: screenWidth * 0.9,
        ),
),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<Widget> construirBotonHorario(ClaseModels clase, Map<int, int> capacidadCache) async {
  final partesFecha = clase.fecha.split('/');
  final diaMes = '${partesFecha[0]}/${partesFecha[1]}';
  final diaYHora = '${clase.dia} $diaMes - ${clase.hora}';

  // Usar la capacidad desde la caché
  final capacidad = capacidadCache[clase.id] ?? 0;
  final estaLlena = clase.mails.length >= capacidad;

  final screenWidth = MediaQuery.of(context).size.width;

  // Verifica si el usuario es administrador
  final esAdmin = await IsAdmin().admin();

  return Column(
    children: [
      SizedBox(
        width: screenWidth * 0.7,
        height: screenWidth * 0.12,
        child: ElevatedButton(
          onPressed: esAdmin
              ? () async {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          clase.mails.isEmpty
                              ? "No hay alumnos inscriptos a esta clase"
                              : "Los alumnos de esta clase son: ${clase.mails.join(', ')}",
                        ),
                        duration: const Duration(seconds: 5),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                  }
                }
              : ((estaLlena ||
                      Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora, mesActual) ||
                      clase.lugaresDisponibles <= 0))
                  ? null
                  : () async {
                      if (context.mounted) {
                        mostrarConfirmacion(context, clase);
                      }
                    },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              estaLlena ||
                      Calcular24hs().esMenorA0Horas(clase.fecha, clase.hora, mesActual) ||
                      clase.lugaresDisponibles <= 0
                  ? Colors.grey.shade400
                  : Colors.green,
            ),
            shape: MaterialStateProperty.all(
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
  }}

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
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: cambiarSemanaAtras,
            icon: Icon(
              Icons.arrow_left,
              size: screenWidth * 0.07,
            ),
          ),
          SizedBox(width: screenWidth * 0.12),
          IconButton(
            onPressed: cambiarSemanaAdelante,
            icon: Icon(
              Icons.arrow_right,
              size: screenWidth * 0.07,
            ),
          ),
        ],
      ),
    );
  }
}

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
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );

          return fecha.month == mesActual;
        }).toList();

        if (filteredFechas.contains(clase.fecha)) {
          return Column(
            children: [
              SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.053,
                child: ElevatedButton(
                  onPressed: () => seleccionarDia(diaMesAnio),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                  child: Text(
                    diaFecha,
                    style: TextStyle(fontSize: screenWidth * 0.033),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
