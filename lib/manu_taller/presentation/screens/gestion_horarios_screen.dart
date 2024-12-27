import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/presentation/functions_screens/box_text.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/manu_taller/widgets/mostrar_dia_segun_fecha.dart';
import 'package:taller_ceramica/models/clase_models.dart';

import '../../../funciones_globales/utils/utils_barril.dart';

class GestionHorariosScreenManu extends StatefulWidget {
  const GestionHorariosScreenManu({super.key});

  @override
  State<GestionHorariosScreenManu> createState() => _GestionHorariosScreenState();
}

class _GestionHorariosScreenState extends State<GestionHorariosScreenManu> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> horariosDisponibles = [];
  List<ClaseModels> horariosFiltrados = [];
  bool isLoading = true;
  List<String> usuariosDisponibles = [];
  String usuarioSeleccionado = "";
  TextEditingController usuarioController = TextEditingController();
  List<String> usuariosDisponiblesOriginal = [];
  bool insertarX4 = false; // Variable para activar/desactivar insertar x4

  @override
  void initState() {
    super.initState();
    fechasDisponibles = GenerarFechasDelMes().generarFechasLunesAViernes();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await ObtenerTotalInfoManu().obtenerClaseManu();
      final usuarios = await ObtenerTotalInfoManu().obtenerUsuariosManu();

      final datosDiciembre = datos.where((clase) {
        final fecha = clase.fecha;
        return fecha.endsWith('/2024');
      }).toList();

      setState(() {
        horariosDisponibles = datosDiciembre;
        horariosFiltrados = datosDiciembre;
        usuariosDisponibles =
            usuarios.map((usuario) => usuario.fullname).toList();
        usuariosDisponiblesOriginal = List.from(usuariosDisponibles);
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
      horariosFiltrados = horariosDisponibles
          .where((clase) => clase.fecha == fechaSeleccionada)
          .toList();
      horariosFiltrados.sort((a, b) {
        final formatoFecha = DateFormat('dd/MM/yyyy');
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
    });
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

  Future<void> mostrarDialogo(
      String tipoAccion, ClaseModels clase, ColorScheme color) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> usuariosFiltrados = List.from(usuariosDisponibles);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(tipoAccion == "insertar"
                  ? "Seleccionar usuario para insertar"
                  : "Seleccionar usuario para remover"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usuarioController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe el nombre del usuario',
                      ),
                      onChanged: (texto) {
                        setStateDialog(() {
                          usuariosFiltrados = usuariosDisponibles
                              .where((usuario) => usuario
                                  .toLowerCase()
                                  .contains(texto.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    usuariosFiltrados.isNotEmpty
                        ? Flexible(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: usuariosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final usuario = usuariosFiltrados[index];
                                  return ListTile(
                                    title: Text(usuario),
                                    onTap: () {
                                      setStateDialog(() {
                                        usuarioSeleccionado = usuario;
                                      });
                                    },
                                    selected: usuarioSeleccionado == usuario,
                                  );
                                },
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("No se encontraron usuarios."),
                          ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tipoAccion == "insertar"
                            ? "Insertar x4"
                            : "Remover x4"),
                        Switch(
                          value: insertarX4,
                          onChanged: (value) {
                            setStateDialog(() {
                              insertarX4 = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (usuarioSeleccionado.isEmpty) return;

                            if (tipoAccion == "insertar") {
                              setState(() {
                                if (insertarX4) {
                                  AgregarUsuarioManu(supabase)
                                      .agregarUsuarioEnCuatroClasesManu(
                                          clase, usuarioSeleccionado);
                                  clase.mails.add(usuarioSeleccionado);
                                } else {
                                  AgregarUsuarioManu(supabase).agregarUsuarioAClaseManu(
                                      clase.id,
                                      usuarioSeleccionado,
                                      true,
                                      clase);
                                  clase.mails.add(usuarioSeleccionado);
                                }
                              });
                            } else if (tipoAccion == "remover") {
                              setState(() {
                                if (insertarX4) {
                                  RemoverUsuarioManu(supabase)
                                      .removerUsuarioDeMuchasClaseManu(
                                          clase, usuarioSeleccionado);
                                  clase.mails.remove(usuarioSeleccionado);
                                } else {
                                  RemoverUsuarioManu(supabase)
                                      .removerUsuarioDeClaseManu(
                                          clase.id, usuarioSeleccionado, true);
                                  clase.mails.remove(usuarioSeleccionado);
                                }
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text(tipoAccion == "insertar"
                              ? "Insertar"
                              : "Remover"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancelar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).primaryColor;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: BoxText(
                        text:
                            "En esta sesión podrás gestionar tus horarios. Ver quiénes asisten a tus clases y agregar o remover usuarios de las mismas")),
                const SizedBox(height: 20),
                MostrarDiaSegunFecha(
                  text: fechaSeleccionada ?? '',
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
                const SizedBox(height: 10),
                if (isLoading) const CircularProgressIndicator(),
                if (!isLoading && fechaSeleccionada != null)
                  Expanded(
                    child: horariosFiltrados.isNotEmpty
                        ? ListView.builder(
                            itemCount: horariosFiltrados.length,
                            itemBuilder: (context, index) {
                              final clase = horariosFiltrados[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            '${clase.hora} - Alumnos/as: ${clase.mails.join(", ")}'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: size.width > 600 ? size.width * 0.15 : size.width * 0.33,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  mostrarDialogo(
                                                      "insertar", clase, colors);
                                                },
                                                child: const Text(
                                                  "Agregar Usuario",
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width > 600 ? size.width * 0.15 : size.width * 0.33,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  mostrarDialogo(
                                                      "remover", clase, colors);
                                                },
                                                child: const Text("Remover Usuario",
                                                    style: TextStyle(fontSize: 10)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                                "No hay horarios disponibles para esta fecha."),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
