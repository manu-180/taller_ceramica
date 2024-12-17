import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/functions/update_user.dart';
import 'package:taller_ceramica/ivanna_taller/utils/capitalize.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/custom_appbar.dart';
import 'package:taller_ceramica/main.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({Key? key}) : super(key: key);

  @override
  _UpdateNameScreenState createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Función para actualizar el nombre en Supabase
  Future<void> _updateName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final listausuarios = await ObtenerTotalInfo().obtenerInfoUsuarios();
      final fullnameExiste = listausuarios.any((usuario) => usuario.fullname.toLowerCase() == _fullnameController.text.toLowerCase());

      if (fullnameExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este nombre ya existe, elige otro.')));
        throw 'El nombre ingresado ya está en uso.';
      }
      if (user == null) {
        throw 'No hay ningún usuario autenticado.';
      }

      // Actualiza los datos del usuario
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {'fullname': Capitalize().capitalize(_fullnameController.text)},
        ),
      );
      await UpdateUser(supabase).updateUser(user.userMetadata?['fullname'], Capitalize().capitalize(_fullnameController.text) );
      await UpdateUser(supabase).updateTableUser(user.id, Capitalize().capitalize(_fullnameController.text) );

      // Éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado con éxito.')),
        );
        _fullnameController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
Widget build(BuildContext context) {
  final color = Theme.of(context).colorScheme;
  return Scaffold(
    appBar: const CustomAppBar(),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto al inicio
            Text(
              'Ingresa tu nuevo nombre:',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color.primary,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 30),
            // Campo de texto
            TextFormField(
              controller: _fullnameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre completo',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, ingresa un nombre válido.';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateName,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Actualizar nombre'),
              ),
            ),
            const SizedBox(height: 16), // Espaciado adicional si es necesario
          ],
        ),
      ),
    ),
  );
}
}