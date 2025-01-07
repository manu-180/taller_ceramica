import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/supabase/redirijir_usuario_al_taller.dart';
import 'dart:convert';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  String passwordError = '';
  String mailError = '';
  bool hasFocusedEmailField = false;
  bool hasFocusedPasswordField = false;

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    _checkSession();
    super.initState();

    // Escuchar cambios de foco en los campos
    emailFocusNode.addListener(() {
      if (emailFocusNode.hasFocus) {
        setState(() {
          hasFocusedEmailField = true;
        });
      }
    });

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        setState(() {
          hasFocusedPasswordField = true;
        });
      }
    });
  }

  Future<void> _checkSession() async {
    // Recuperar la sesión desde SharedPreferences
    final user = Supabase.instance.client.auth.currentUser;

    // Si la sesión es válida, redirigir al usuario
    if (user != null) {
      await RedirigirUsuarioAlTaller().redirigirUsuario(context);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller de Ceramica', style: TextStyle(color: Colors.white),),
        backgroundColor: color.primary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(size.width * 0.05, 20, size.width * 0.05, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.primary.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Si sos administrador y aun no te has creado tu propia cuenta ¡crea un taller nuevo!.\nSi sos alumno, necesitas que el administrador te cree la cuenta",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: size.width * 0.04 ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Inicia sesión : ',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: color.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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
                            mailError =
                                !emailRegex.hasMatch(emailController.text.trim())
                                    ? 'El correo electrónico es invalido.'
                                    : '';
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: const OutlineInputBorder(),
                          errorText: passwordError.isEmpty ? null : passwordError,
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
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  context.push("/creartaller");
                                },
                                child: const Text("Crear Taller")),
                            const SizedBox(width: 20),
                            FilledButton(
                              onPressed: () async {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
              
                                if (!emailRegex.hasMatch(email)) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('El correo no es válido'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
              
                                if (password.length < 6) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'La contraseña debe tener al menos 6 caracteres'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
              
                                try {
                                  // Iniciar sesión
                                  final response = await Supabase.instance.client.auth
                                      .signInWithPassword(
                                    email: email,
                                    password: password,
                                  );
              
                                  // Guardar sesión manualmente (SharedPreferences)
                                  if (response.session != null) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final sessionData = response.session!.toJson();
              
                                    // Convertir sessionData en una cadena JSON antes de guardarlo
                                    await prefs.setString(
                                        'session', jsonEncode(sessionData));
                                  }
                                  if (context.mounted) {
                                    RedirigirUsuarioAlTaller()
                                        .redirigirUsuario(context);
                                  }
                                  return;
                                } on AuthException catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error de inicio de sesión: ${e.message}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  return;
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ocurrió un error inesperado'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              },
                              child: const Text('Iniciar Sesión'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
