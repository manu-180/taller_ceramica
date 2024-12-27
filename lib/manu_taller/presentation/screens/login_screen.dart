import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';


class LoginScreenManu extends StatefulWidget {
  const LoginScreenManu({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreenManu> {
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
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
      body: Center(
        child: ConstrainedBox(
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
                      mailError = !emailRegex.hasMatch(emailController.text.trim())
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
                ElevatedButton(
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
                      final response =
                          await Supabase.instance.client.auth.signInWithPassword(
                        email: email,
                        password: password,
                      );
          
                      // Guardar sesión manualmente (SharedPreferences)
                      if (response.session != null) {
                        final prefs = await SharedPreferences.getInstance();
                        final sessionData = response.session!.toJson();
          
                        // Convertir sessionData en una cadena JSON antes de guardarlo
                        await prefs.setString('session', jsonEncode(sessionData));
                      }
                      if (context.mounted) {
                        context.push('/homeivanna');
                      }
                      return;
                    } on AuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error de inicio de sesión: ${e.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        ),
      ),
    );
  }
}
