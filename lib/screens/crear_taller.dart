import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/utils/utils_barril.dart';

class CrearTallerScreen extends StatefulWidget {
  const CrearTallerScreen({super.key});

  @override
  State<CrearTallerScreen> createState() => _CrearTallerScreenState();
}

class _CrearTallerScreenState extends State<CrearTallerScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tallerController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String passwordError = '';
  String confirmPasswordError = '';
  String mailError = '';
  String tallerError = '';
  bool isLoading = false;

  Future<void> crearTablaTaller(String taller) async {
    final int mesActual = DateTime.now().month;

    await supabase.rpc('create_table', params: {
      'query': '''
    CREATE TABLE IF NOT EXISTS "$taller" (
      id SERIAL PRIMARY KEY,
      semana TEXT NOT NULL,
      dia TEXT NOT NULL,
      fecha TEXT NOT NULL,
      hora TEXT NOT NULL,
      mails JSONB DEFAULT '[]',
      lugar_disponible INTEGER NOT NULL DEFAULT 0,
      mes INTEGER NOT NULL DEFAULT $mesActual,
      capacidad INTEGER NOT NULL DEFAULT 0

    );
  '''
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Taller de Ceramica',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: BoxText(
                      text:
                          "Antes de crear tu taller, te invitamos a leer brevemente más información sobre cómo funciona nuestra aplicación. Esto te ayudará a aprovechar al máximo todas sus funcionalidades."),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              '¿Qué puede hacer nuestra aplicación?'),
                          content: SingleChildScrollView(
                            child: const Text(
                                'Nuestra aplicación está diseñada para revolucionar la gestión de tu taller de cerámica. ¡Descubre todo lo que puedes lograr con ella!\n\n'
                                '**Para los alumnos:**\n'
                                '- Explora todas las clases disponibles con botones en verde para inscribirte fácilmente. ¡Es sencillo y rápido inscribirte en tus clases favoritas!\n'
                                '- Gestiona tus clases: revisa las que tienes inscritas y cancélalas si es necesario. Si cancelas con un día de anticipación, obtendrás un crédito para recuperarla más adelante. ¡Fácil y justo!\n\n'
                                '**Para los administradores:**\n'
                                '- Gestiona a tus alumnos como un experto: asigna créditos para inscribirse, elimina usuarios de clases o agrégalos, ¡incluso si la clase ya está llena! Todo al alcance de tu mano.\n'
                                '- Visualiza tus clases de manera eficiente: selecciona una fecha y obtén una vista detallada de quiénes asistirán. Podrás hacer ajustes de manera rápida y sencilla.\n'
                                '- Crea nuevas clases o elimínalas sin complicaciones, asegurando que tu taller esté siempre organizado y funcionando a la perfección.\n\n'
                                '**¿Lo mejor?** Mientras los alumnos se manejan de forma autónoma, tú recibirás notificaciones automáticas por WhatsApp con cada inscripción, manteniéndote al tanto sin esfuerzo.\n\n'
                                '**Personalización para todos los usuarios:**\n'
                                '- Cambia el color del tema de la aplicación desde la pantalla de configuración, dándole tu propio estilo.\n'
                                '- Actualiza los datos de tu cuenta de manera sencilla y sin complicaciones.\n\n'
                                '**Importante:**\n'
                                'Ten en cuenta que la aplicación incluye un mes de prueba gratuito. ¡No necesitas ingresar ningún medio de pago para disfrutar de esta experiencia inicial!\n'
                                'Una vez finalizado el mes, si decides seguir disfrutando de todas las funcionalidades, deberás pagar una suscripción de \$40. ¡Es el momento de llevar tu taller al siguiente nivel!\n\n'
                                '¡Empieza hoy mismo y transforma la forma en que gestionas tu taller de cerámica!'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.info_outline), // Icono en el botón
                  label: const Text('Más Información'),
                ),
                SizedBox(
                  height: size.width * 0.05,
                )
              ],
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: fullnameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre y apellido',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            border: const OutlineInputBorder(),
                            errorText: mailError.isEmpty ? null : mailError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              mailError = !emailRegex
                                      .hasMatch(emailController.text.trim())
                                  ? 'El correo electrónico es inválido.'
                                  : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: tallerController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del taller',
                            border: const OutlineInputBorder(),
                            errorText: tallerError.isEmpty ? null : tallerError,
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {
                              tallerError = tallerController.text.trim().isEmpty
                                  ? 'El nombre del taller no puede estar vacío.'
                                  : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            errorText:
                                passwordError.isEmpty ? null : passwordError,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              passwordError = value.length < 6
                                  ? 'La contraseña debe tener al menos 6 caracteres.'
                                  : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            border: const OutlineInputBorder(),
                            errorText: confirmPasswordError.isEmpty
                                ? null
                                : confirmPasswordError,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              confirmPasswordError =
                                  value != passwordController.text
                                      ? 'La contraseña no coincide.'
                                      : '';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () => context.go("/"),
                                child: Text("Volver atras")),
                            SizedBox(width: 15),
                            FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      FocusScope.of(context).unfocus();
                                      final fullname =
                                          fullnameController.text.trim();
                                      final email = emailController.text.trim();
                                      final taller =
                                          tallerController.text.trim();
                                      final password =
                                          passwordController.text.trim();
                                      final confirmPassword =
                                          confirmPasswordController.text.trim();

                                      if (fullname.isEmpty ||
                                          email.isEmpty ||
                                          taller.isEmpty ||
                                          password.isEmpty ||
                                          confirmPassword.isEmpty) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            'Todos los campos son obligatorios.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                        return;
                                      }

                                      if (password.length < 6) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            'La contraseña debe tener al menos 6 caracteres.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                        return;
                                      }

                                      if (password != confirmPassword) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            'La contraseña no coincide.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                        return;
                                      }

                                      try {
                                        final AuthResponse res =
                                            await supabase.auth.signUp(
                                          email: email,
                                          password: password,
                                          data: {
                                            'fullname': Capitalize()
                                                .capitalize(fullname)
                                          },
                                        );

                                        await supabase.from('usuarios').insert({
                                          'id': await GenerarId()
                                              .generarIdUsuario(),
                                          'usuario': email,
                                          'fullname':
                                              Capitalize().capitalize(fullname),
                                          'user_uid': res.user?.id,
                                          'sexo': "mujer",
                                          'clases_disponibles': 0,
                                          'trigger_alert': 0,
                                          'clases_canceladas': [],
                                          'taller':
                                              Capitalize().capitalize(taller),
                                          "admin": true,
                                          "created_at":
                                              DateTime.now().toIso8601String(),
                                        });

                                        crearTablaTaller(
                                            Capitalize().capitalize(taller));

                                        if (context.mounted) {
                                          context.go("/");
                                        }

                                        //  EnviarWpp().sendWhatsAppMessage(
                                        // "HXd8748cc9c7d60600cfda07262b4710df",
                                        // 'whatsapp:+5491134272488',
                                        // [Capitalize().capitalize(fullname), taller, email]
                                        //   );

                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                              '¡Taller creado exitosamente!',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.green,
                                          ));
                                        }
                                      } catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              'Error al crear el taller: $e',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Text('Registrar Taller'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
