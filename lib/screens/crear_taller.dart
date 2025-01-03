import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/utils/capitalize.dart';
import 'package:taller_ceramica/utils/enviar_wpp.dart';

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
      mes INTEGER NOT NULL DEFAULT 1
    );
  '''
});

  }
  

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Crea tu Taller',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        confirmPasswordError =
                            value != passwordController.text
                                ? 'La contraseña no coincide.'
                                : '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });

                            FocusScope.of(context).unfocus();
                            final fullname = fullnameController.text.trim();
                            final email = emailController.text.trim();
                            final taller = tallerController.text.trim();
                            final password = passwordController.text.trim();
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
                                  style: TextStyle(color: Colors.white),
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
                                  style: TextStyle(color: Colors.white),
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
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            try {
                              final AuthResponse res = await supabase.auth.signUp(
                          email: email,
                          password: password,
                          data: {'fullname': Capitalize().capitalize(fullname)},
                        );

                        await supabase.from('usuarios').insert({
                          'id': await GenerarId().generarIdUsuario(),
                          'usuario': email,
                          'fullname': Capitalize().capitalize(fullname),
                          'user_uid': res.user?.id,
                          'sexo': "mujer",
                          'clases_disponibles': 0,
                          'trigger_alert': 0,
                          'clases_canceladas': [],
                          'taller':taller,
                          "admin": true
                        });

                        crearTablaTaller(taller);

                        if (context.mounted){
                          context.go("/");
                        }

                        EnviarWpp().sendWhatsAppMessage(
                            '${Capitalize().capitalize(fullname)} ¡CREO UN NUEVO TALLER! "$taller". Contactalo por mail: $email',
                            'whatsapp:+5491134272488');

                              setState(() {
                                isLoading = false;
                              });
                              if(context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  '¡Taller creado exitosamente!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              if (context.mounted){
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  'Error al crear el taller: $e',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              }
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Registrar Taller'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
