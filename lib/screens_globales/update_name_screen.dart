import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/funciones_globales/utils/capitalize.dart';

class UpdateNameScreen extends StatefulWidget {
  final Future<List<dynamic>> Function() obtenerUsuarios;
  final Future<void> Function(String, String) updateUser;
  final Future<void> Function(String, String) updateTableUser;
  final PreferredSizeWidget appBar;

  const UpdateNameScreen({
    super.key,
    required this.obtenerUsuarios,
    required this.updateUser,
    required this.updateTableUser,
    required this.appBar,
  });

  @override
  UpdateNameScreenState createState() => UpdateNameScreenState();
}

class UpdateNameScreenState extends State<UpdateNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updateName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final listausuarios = await widget.obtenerUsuarios();
      final fullnameExiste = listausuarios.any((usuario) =>
          usuario.fullname.toLowerCase() ==
          _fullnameController.text.toLowerCase());

      if (fullnameExiste) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este nombre ya existe, elige otro.')),
          );
        }
        throw 'El nombre ingresado ya está en uso.';
      }

      if (user == null) {
        throw 'No hay ningún usuario autenticado.';
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {'fullname': Capitalize().capitalize(_fullnameController.text)},
        ),
      );

      await widget.updateUser(
        user.userMetadata?['fullname'] ?? '',
        Capitalize().capitalize(_fullnameController.text),
      );

      await widget.updateTableUser(
        user.id,
        Capitalize().capitalize(_fullnameController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado con éxito.')),
        );
        _fullnameController.clear();
      }
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
      appBar: widget.appBar,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingresa tu nuevo nombre:',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: color.primary,
                ),
              ),
              const SizedBox(height: 30),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Actualizar nombre'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
