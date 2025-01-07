// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/eliminar_clase.dart';
import 'package:taller_ceramica/supabase/generar_id.dart';
import 'package:taller_ceramica/supabase/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/obtener_total_info.dart';
import 'package:taller_ceramica/utils/utils_barril.dart';
import 'package:taller_ceramica/main.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';

import '../widgets/mostrar_dia_segun_fecha.dart';

class GestionDeClasesScreen extends StatefulWidget {
  const GestionDeClasesScreen({super.key, String? taller});

  @override
  State<GestionDeClasesScreen> createState() => _GestionDeClasesScreenState();
}

class _GestionDeClasesScreenState extends State<GestionDeClasesScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> clasesDisponibles = [];
  List<ClaseModels> clasesFiltradas = [];
  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    inicializarDatos();
    SubscriptionVerifier.verificarAdminYSuscripcion(context);
  }

  Future<void> inicializarDatos() async {
    try {
      // Obtener el mes de forma asíncrona
      final mes = await ObtenerMes().obtenerMes();
      setState(() {
        fechasDisponibles =
            GenerarFechasDelMes().generarFechasDelMes(mes, 2025);
      });

      await cargarDatos();
    } catch (e) {
      debugPrint('Error al inicializar los datos: $e');
    }
  }

  void ordenarClasesPorFechaYHora() {
    clasesFiltradas.sort((a, b) {
      final formatoFecha = DateFormat('dd/MM');
      final fechaA = formatoFecha.parse(a.fecha);
      final fechaB = formatoFecha.parse(b.fecha);

      if (fechaA == fechaB) {
        final formatoHora = DateFormat('HH:mm');
        final horaA = formatoHora.parse(a.hora);
        final horaB = formatoHora.parse(b.hora);
        return horaA.compareTo(horaB);
      }
      return fechaA.compareTo(fechaB);
    });
  }

  Future<void> cargarDatos() async {
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    try {
      final datos = await ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller,
      ).obtenerClases();

      setState(() {
        clasesDisponibles = List<ClaseModels>.from(datos);
        clasesFiltradas = List.from(datos); // Copia de datos para filtrar
        ordenarClasesPorFechaYHora(); // Ordenar antes de mostrar
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error cargando datos: $e');
    }
  }

  void seleccionarFecha(String fecha) {
    setState(() {
      fechaSeleccionada = fecha;
      clasesFiltradas = clasesDisponibles.where((clase) {
        return clase.fecha == fechaSeleccionada;
      }).toList();
    });
  }

  Future<void> agregarLugar(int id) async {
    setState(() {
      final index = clasesFiltradas.indexWhere((clase) => clase.id == id);
      if (index != -1) {
        clasesFiltradas[index].lugaresDisponibles++;
      }
    });
  }

  Future<void> quitarLugar(int id) async {
    setState(() {
      final index = clasesFiltradas.indexWhere((clase) => clase.id == id);
      if (index != -1 && clasesFiltradas[index].lugaresDisponibles > 0) {
        clasesFiltradas[index].lugaresDisponibles--;
      }
    });
  }

  // Función para mostrar el diálogo de confirmación
  Future<bool?> mostrarDialogoConfirmacion(
      BuildContext context, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // "No"
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // "Sí"
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
  }

  String obtenerDia(DateTime fecha) {
    // Utiliza el parámetro 'fecha' de tipo DateTime correctamente
    switch (fecha.weekday) {
      case DateTime.monday:
        return 'lunes';
      case DateTime.tuesday:
        return 'martes';
      case DateTime.wednesday:
        return 'miercoles';
      case DateTime.thursday:
        return 'jueves';
      case DateTime.friday:
        return 'viernes';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'Desconocido';
    }
  }

  Future<void> mostrarDialogoAgregarClase(String dia) async {
    final size = MediaQuery.of(context).size;
    final usuarioActivo = Supabase.instance.client.auth.currentUser;
    final taller = await ObtenerTaller().retornarTaller(usuarioActivo!.id);

    TextEditingController horaController = TextEditingController();
    TextEditingController capacidadController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Agregar nueva clase todos los $dia"),
              content: isProcessing
                  ? null
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: horaController,
                          decoration: const InputDecoration(
                            hintText: 'Ingrese la hora de la clase (HH:mm)',
                          ),
                        ),
                      TextField(
                          controller: capacidadController,
                          decoration: const InputDecoration(
                            hintText: 'Ingrese limite de alumnos',
                          ),
                        ),
                      
                    ],
                  ),
              actions: [
                if (isProcessing)
                  ElevatedButton.icon(
                    onPressed: null, 
                    icon: SizedBox(
                        width: size.width * 0.05,
                        height: size.width * 0.05,
                        child: CircularProgressIndicator(
                          strokeWidth: size.width * 0.006,
                        )),
                    label: const Text("Cargando clases"),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: () async {
                      setStateDialog(() {
                        isProcessing = true;
                      });

                      try {
                        final hora = horaController.text.trim();
                        if (hora.isEmpty || fechaSeleccionada == null) {
                          throw Exception(
                              "Debe ingresar una hora y fecha válida.");
                        }

                        final capacidadText = capacidadController.text.trim();
                        final capacidad = int.tryParse(capacidadText);

                        if (capacidad == null) {
                          throw Exception("Debe ingresar un valor numérico.");
                        }

                        final horaFormatoValido =
                            RegExp(r'^\d{2}:\d{2}$').hasMatch(hora);
                        if (!horaFormatoValido) {
                          throw Exception(
                              "Formato de hora inválido. Usa HH:mm (ejemplo: 14:30).");
                        }

                        final partesHora = hora.split(':');
                        final hh = int.tryParse(partesHora[0]) ?? -1;
                        final mm = int.tryParse(partesHora[1]) ?? -1;

                        if (hh < 0 || hh > 23 || mm < 0 || mm > 59) {
                          throw Exception(
                              "La hora debe estar entre 00:00 y 23:59.");
                        }

                        DateTime fechaBase =
                            DateFormat('dd/MM/yyyy').parse(fechaSeleccionada!);
                        DateTime firstDayOfMonth =
                            DateTime(fechaBase.year, fechaBase.month, 1);
                        int dayOfWeekSelected = fechaBase.weekday;
                        int difference =
                            (7 + dayOfWeekSelected - firstDayOfMonth.weekday) %
                                7;

                        DateTime firstTargetDate =
                            firstDayOfMonth.add(Duration(days: difference));

                        for (int i = 0; i < 5; i++) {
                          final fechaSemana =
                              firstTargetDate.add(Duration(days: 7 * i));
                          final fechaStr =
                              DateFormat('dd/MM/yyyy').format(fechaSemana);
                          final diaSemana = obtenerDia(fechaSemana);

                          final existingClass = await supabase
                              .from(taller)
                              .select()
                              .eq('fecha', fechaStr)
                              .eq('hora', hora)
                              .maybeSingle();

                          if (existingClass != null) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'La clase del $fechaStr a las $hora ya existe.',
                                ),
                              ),
                            );
                            continue;
                          }

                          await supabase.from(taller).insert({
                            'id': await GenerarId().generarIdClase(),
                            'semana': "semana${i + 1}",
                            'dia': diaSemana,
                            'fecha': fechaStr,
                            'hora': hora,
                            'mails': [],
                            'lugar_disponible': capacidad,
                            'capacidad': capacidad,
                          });
                        }

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Clases agregadas con éxito.'),
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      } finally {
                        setStateDialog(() {
                          isProcessing = false;
                        });
                      }
                    },
                    child: const Text("Agregar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancelar"),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void cambiarFecha(bool siguiente) {
    setState(() {
      if (fechaSeleccionada != null) {
        final int indexActual = fechasDisponibles.indexOf(fechaSeleccionada!);

        if (siguiente) {
          // Ir a la siguiente fecha y volver al inicio si es la última
          fechaSeleccionada =
              fechasDisponibles[(indexActual + 1) % fechasDisponibles.length];
        } else {
          // Ir a la fecha anterior y volver al final si es la primera
          fechaSeleccionada = fechasDisponibles[
              (indexActual - 1 + fechasDisponibles.length) %
                  fechasDisponibles.length];
        }
        seleccionarFecha(fechaSeleccionada!);
      } else {
        fechaSeleccionada = fechasDisponibles[0];
        seleccionarFecha(fechaSeleccionada!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar:
          ResponsiveAppBar(isTablet: MediaQuery.of(context).size.width > 600),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 600), // Ancho máximo de 600
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: BoxText(
                    text:
                        "En esta sección podrás gestionar las clases disponibles. Agregar o remover lugares, eliminar clases y agregar nuevas clases."),
              ),
              const SizedBox(height: 10),
              MostrarDiaSegunFecha(
                text: fechaSeleccionada ?? '-',
                colors: colors,
                color: color,
                cambiarFecha: cambiarFecha,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: fechaSeleccionada,
                hint: const Text('Selecciona una fecha'),
                onChanged: (value) {
                  seleccionarFecha(value!);
                },
                items: fechasDisponibles.map((fecha) {
                  return DropdownMenuItem(
                    value: fecha,
                    child: Text(fecha),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (!isLoading &&
                  fechaSeleccionada != null &&
                  clasesFiltradas.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: clasesFiltradas.length,
                    itemBuilder: (context, index) {
                      final clase = clasesFiltradas[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              '${clase.hora} - Lugares disponibles: ${clase.lugaresDisponibles}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  bool? respuesta =
                                      await mostrarDialogoConfirmacion(context,
                                          "¿Quieres agregar un lugar disponible a esta clase?");
                                  if (respuesta == true) {
                                    agregarLugar(clase.id);
                                    ModificarLugarDisponible()
                                        .agregarLugarDisponible(clase.id);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () async {
                                  bool? respuesta =
                                      await mostrarDialogoConfirmacion(context,
                                          "¿Quieres remover un lugar disponible a esta clase?");
                                  if (respuesta == true &&
                                      clase.lugaresDisponibles > 0) {
                                    quitarLugar(clase.id);
                                    ModificarLugarDisponible()
                                        .removerLugarDisponible(clase.id);
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool? respuesta =
                                      await mostrarDialogoConfirmacion(context,
                                          "¿Estás seguro/a que quieres eliminar esta clase?");
                                  if (respuesta == true) {
                                    setState(() {
                                      clasesFiltradas.removeAt(index);
                                      EliminarClase().eliminarClase(clase.id);
                                    });
                                  }
                                },
                              ),
                            ],
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
        width: 200,
        child: FloatingActionButton(
          backgroundColor: colors.secondaryContainer,
          onPressed: () {
            if (fechaSeleccionada == null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Por favor, selecciona una fecha antes de agregar clases.'),
                ),
              );
              return;
            }
            mostrarDialogoAgregarClase(
                DiaConFecha().obtenerDiaDeLaSemana(fechaSeleccionada!));
          },
          child: const Text("Crear una clase nueva"),
        ),
      ),
    );
  }
}
