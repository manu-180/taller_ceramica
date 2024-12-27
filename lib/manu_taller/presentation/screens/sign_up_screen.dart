// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/manu_taller/supabase/supabase_barril.dart';
import '../../../funciones_globales/utils_barril.dart';

class SignUpScreenManu extends StatefulWidget {
  const SignUpScreenManu({super.key});

  @override
  State<SignUpScreenManu> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreenManu> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String passwordError = '';
  String confirmPasswordError = '';
  String mailError = '';
  bool showSuccessMessage = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ResponsiveAppBarManu( isTablet: size.width > 600),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600 ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Crea tu usuario y contraseña : ',
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
                        mailError =
                            !emailRegex.hasMatch(emailController.text.trim())
                                ? 'El correo electrónico es invalido.'
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
                        confirmPasswordError = value != passwordController.text
                            ? 'La contraseña no coincide.'
                            : '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
          
                      FocusScope.of(context).unfocus();
                      final fullname = fullnameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      final confirmPassword =
                          confirmPasswordController.text.trim();
          
                      if (fullname.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Todos los campos son obligatorios.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
          
                      if (password.length < 6) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La contraseña debe tener al menos 6 caracteres.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
          
                      if (password != confirmPassword) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La contraseña no coincide.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
          
                      try {
                        final listausuarios =
                            await ObtenerTotalInfoManu().obtenerUsuariosManu();
          
                        final emailExiste = listausuarios
                            .any((usuario) => usuario.usuario == email);
                        final fullnameExiste = listausuarios.any((usuario) =>
                            usuario.fullname.toLowerCase() ==
                            fullname.toLowerCase());
          
                        if (emailExiste) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El correo electrónico ya está registrado. Usa otro.',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
          
                        if (fullnameExiste) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El nombre completo ya existe. Usa uno diferente para no generar conflictos.',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
          
                        final AuthResponse res = await supabase.auth.signUp(
                          email: email,
                          password: password,
                          data: {'fullname': Capitalize().capitalize(fullname)},
                        );
          
                        await supabase.from('usuariosmanu').insert({
                          'id': await GenerarIdManu().generarIdUsuarioManu(),
                          'usuario': email,
                          'fullname': Capitalize().capitalize(fullname),
                          'user_uid': res.user?.id,
                          'sexo': "mujer",
                          'clases_disponibles': 0,
                          'trigger_alert': 0,
                          'clases_canceladas': [],
                        });
          
                        EnviarWpp().sendWhatsAppMessage(
                            "${Capitalize().capitalize(fullname)} creo una cuenta. Ya esta disponible para asignar sus clases",
                            'whatsapp:+5491132820164');
                        EnviarWpp().sendWhatsAppMessage(
                            "${Capitalize().capitalize(fullname)} creo una cuenta. Ya esta disponible para asignar sus clases",
                            'whatsapp:+5491134272488');
          
                        setState(() {
                          isLoading = false;
                          showSuccessMessage = true;
                        });
          
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Registro exitoso!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
          
                        Future.delayed(const Duration(seconds: 30), () {
                          setState(() {
                            showSuccessMessage = false;
                          });
                        });
                      } on AuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error de registro: ${e.message}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ocurrió un error inesperado: ($e).',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Registrar'),
                  ),
                  // Aquí mostramos el mensaje de éxito
                  if (showSuccessMessage) ...[
                    const SizedBox(height: 30),
                    const BoxText(
                        text:
                            "¡Registro exitoso! El siguiente paso: verifica tu correo para verificarte presionando el link."),
                  ],
                  if (isLoading) ...[
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
