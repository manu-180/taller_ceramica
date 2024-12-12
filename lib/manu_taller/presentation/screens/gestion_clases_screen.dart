// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/ivanna_taller/models/clase_models.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/functions_screens/box_text.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/eliminar_clase.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/generar_id.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/utils/dia_con_fecha.dart';
import 'package:taller_ceramica/ivanna_taller/utils/generar_fechas_del_mes.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/mostrar_dia_segun_fecha.dart';

class GestionDeClasesScreen extends StatefulWidget {
  const GestionDeClasesScreen({super.key});

  @override
  State<GestionDeClasesScreen> createState() => _GestionDeClasesScreenState();
}

class _GestionDeClasesScreenState extends State<GestionDeClasesScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> clasesDisponibles = [];
  List<ClaseModels> clasesFiltradas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fechasDisponibles = GenerarFechasDelMes().generarFechasLunesAViernes();
    cargarDatos();
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
    try {
      final datos = await ObtenerTotalInfo().obtenerInfo();

      setState(() {
        clasesDisponibles = datos;
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
        return 'Desconocido'; // En caso de que falle la conversión
    }
  }

  Future<void> mostrarDialogoAgregarClase(String dia) async {
    TextEditingController horaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Agregar nueva clase todos los $dia"),
          content: TextField(
            controller: horaController,
            decoration: const InputDecoration(
              hintText: 'Ingrese la hora de la clase (HH:mm)',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final hora = horaController.text;
                if (hora.isNotEmpty && fechaSeleccionada != null) {
                  final horaFormatoValido =
                      RegExp(r'^\d{2}:\d{2}$').hasMatch(hora);

                  if (!horaFormatoValido) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Formato de hora inválido. Asegúrate de usar HH:mm (por ejemplo, 14:30).'),
                      ),
                    );
                    return;
                  }

                  // Convertir la fecha seleccionada de String a DateTime
                  DateTime fechaBase;
                  try {
                    fechaBase =
                        DateFormat('dd/MM/yyyy').parse(fechaSeleccionada!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Formato de fecha inválido. Use dd/MM/yyyy.'),
                      ),
                    );
                    return;
                  }

                  // Aquí, 'obtenerDia' ahora recibe un DateTime y funciona correctamente
                  final dia = obtenerDia(fechaBase);

                  for (int i = 0; i < 5; i++) {
                    final fechaSemana = fechaBase.add(Duration(days: 7 * i));
                    final fechaStr =
                        DateFormat('dd/MM/yyyy').format(fechaSemana);

                    // Verificar si ya existe una clase con la misma fecha y hora
                    final existingClass = await supabase
                        .from('respaldo')
                        .select()
                        .eq('fecha', fechaStr)
                        .eq('hora', hora)
                        .maybeSingle();

                    if (existingClass != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'La clase del $fechaStr a las $hora ya existe.'),
                        ),
                      );
                      continue; // No insertar esta clase, pasa a la siguiente iteración
                    }

                    // Insertar la nueva clase si no existe
                    try {
                      await supabase.from('respaldo').insert({
                        'id': await GenerarId().generarIdClase(),
                        'semana': "semana${i + 1}",
                        'dia': dia,
                        'fecha': fechaStr,
                        'hora': hora,
                        'mails': [],
                        'lugar_disponible': 5,
                      });
                    } catch (e) {
                      debugPrint('Error al insertar clase: $e');
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clases agregadas con éxito.'),
                    ),
                  );
                  Navigator.of(context).pop();
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
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: BoxText(
                text:
                    "En esta sección podrás gestionar las clases disponibles. Agregar o remover lugares, eliminar clases y agregar nuevas clases."),
          ),
          const SizedBox(
            height: 10,
          ),
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
                              // Muestra un diálogo de confirmación antes de agregar el crédito
                              bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
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
                              // Muestra un diálogo de confirmación antes de remover el crédito
                              bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Muestra un diálogo de confirmación antes de eliminar la clase
                              bool? respuesta = await mostrarDialogoConfirmacion(
                                  context,
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
      floatingActionButton: SizedBox(
        width: 200,
        child: FloatingActionButton(
          backgroundColor: colors.secondaryContainer,
          onPressed: () {
            if (fechaSeleccionada == null) {
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

class _DiaSeleccionado extends StatelessWidget {
  const _DiaSeleccionado({
    required this.text,
    required this.colors,
    required this.color,
  });

  final ColorScheme colors;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.secondaryContainer, colors.primary.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text.isEmpty ? "-" : DiaConFecha().obtenerDiaDeLaSemana(text),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
