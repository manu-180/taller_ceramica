import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/subscription/subscription_verifier.dart';
import 'package:taller_ceramica/supabase/agregar_usuario.dart';
import 'package:taller_ceramica/supabase/obtener_mes.dart';
import 'package:taller_ceramica/supabase/obtener_taller.dart';
import 'package:taller_ceramica/supabase/obtener_total_info.dart';
import 'package:taller_ceramica/supabase/remover_usuario.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/utils/actualizar_fechas_database.dart';
import 'package:taller_ceramica/widgets/box_text.dart';
import 'package:taller_ceramica/utils/generar_fechas_del_mes.dart';
import 'package:taller_ceramica/widgets/mostrar_dia_segun_fecha.dart';
import 'package:taller_ceramica/widgets/responsive_appbar.dart';

class GestionHorariosScreen extends StatefulWidget {
  const GestionHorariosScreen({super.key, String? taller});

  @override
  State<GestionHorariosScreen> createState() => _GestionHorariosScreenState();
}

class _GestionHorariosScreenState extends State<GestionHorariosScreen> {
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
  final actualizarFechasDatabase = ActualizarFechasDatabase();

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
      });

      await cargarDatos();
    } catch (e) {
      debugPrint('Error al inicializar los datos: $e');
    }
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
      final usuarios = await ObtenerTotalInfo(
        supabase: supabase,
        usuariosTable: 'usuarios',
        clasesTable: taller,
      ).obtenerUsuarios();

      final datosDiciembre = datos.where((clase) {
        final fecha = clase.fecha;
        return fecha.endsWith('/2025');
      }).toList();

      final usuariosFiltrados = usuarios.where((usuario) {
        return usuario.taller == taller;
      }).toList();

      final nombresFiltrados =
          usuariosFiltrados.map((usuario) => usuario.fullname).toList();

      setState(() {
        horariosDisponibles = datosDiciembre.cast<ClaseModels>();
        horariosFiltrados = datosDiciembre.cast<ClaseModels>();

        usuariosDisponibles = nombresFiltrados.cast<String>();
        usuariosDisponiblesOriginal = List.from(nombresFiltrados);

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
  onPressed: () async {
    // 1. Si no hay usuario seleccionado, salimos
    if (usuarioSeleccionado.isEmpty) return;

    // 2. Cerramos el cartel de inmediato
    Navigator.of(context).pop();

    // 3. Ahora ejecutamos el proceso asíncrono en segundo plano
    if (tipoAccion == "insertar") {
      if (insertarX4) {
        // Inserta en 4 clases
        await AgregarUsuario(supabase).agregarUsuarioEnCuatroClases(
          clase,
          usuarioSeleccionado,
          (ClaseModels claseActualizada) {
            // 4. Si la pantalla principal todavía está montada, actualizamos
            if (mounted) {
              setState(() {
                final idx = horariosDisponibles
                    .indexWhere((c) => c.id == claseActualizada.id);
                if (idx != -1) {
                  horariosDisponibles[idx] = claseActualizada;
                }

                final idxFiltrado = horariosFiltrados
                    .indexWhere((c) => c.id == claseActualizada.id);
                if (idxFiltrado != -1) {
                  horariosFiltrados[idxFiltrado] = claseActualizada;
                }
              });
            }
          },
        );
      } else {
        // Inserta en una sola clase
        await AgregarUsuario(supabase).agregarUsuarioAClase(
          clase.id,
          usuarioSeleccionado,
          true,
          clase,
        );
        // 4. Actualizamos la pantalla principal si sigue montada
        if (mounted) {
          setState(() {
            clase.mails.add(usuarioSeleccionado);
          });
        }
      }
    } else if (tipoAccion == "remover") {
  if (insertarX4) {
    // Remueve de 4 clases
    await RemoverUsuario(supabase).removerUsuarioDeMuchasClase(
      clase,
      usuarioSeleccionado,
      (ClaseModels claseActualizada) {
        // Este callback se llama cada vez que se hace un "remove" en una de las clases
        if (mounted) {
          setState(() {
            // Buscamos la clase por ID y actualizamos la lista local
            final idx = horariosDisponibles.indexWhere(
              (c) => c.id == claseActualizada.id,
            );
            if (idx != -1) {
              horariosDisponibles[idx] = claseActualizada;
            }

            final idxFiltrado = horariosFiltrados.indexWhere(
              (c) => c.id == claseActualizada.id,
            );
            if (idxFiltrado != -1) {
              horariosFiltrados[idxFiltrado] = claseActualizada;
            }
          });
        }
      },
    );
  } else {
    // Remueve de una sola clase
    await RemoverUsuario(supabase).removerUsuarioDeClase(
      clase.id,
      usuarioSeleccionado,
      true,
    );
    if (mounted) {
      setState(() {
        clase.mails.remove(usuarioSeleccionado);
      });
    }
  }
}

  },
  child: Text(tipoAccion == "insertar" ? "Insertar" : "Remover"),
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
      appBar: ResponsiveAppBar(isTablet: size.width > 600),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: colors.primary,
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: colors.primary
                                                      .withOpacity(0.1),
                                                ),
                                                child: Text(
                                                  clase.hora,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "- Alumnos :",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(clase.mails.join(", ")),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: size.width > 600
                                                  ? size.width * 0.15
                                                  : size.width * 0.33,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  mostrarDialogo("insertar",
                                                      clase, colors);
                                                },
                                                child: const Text(
                                                  "Agregar Usuario",
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width > 600
                                                  ? size.width * 0.15
                                                  : size.width * 0.33,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  mostrarDialogo(
                                                      "remover", clase, colors);
                                                },
                                                child: const Text(
                                                    "Remover Usuario",
                                                    style: TextStyle(
                                                        fontSize: 10)),
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
