import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedStrings = {
    'en': {
      'helloWorld': 'Hello World!',
      'errorLoadingData': 'Error loading data',
      'welcomeFemale': 'Welcome to the \$taller workshop!',
      'welcomeMale': 'Welcome to the \$taller workshop!',
      'helloAnonymous':
          'Hello and welcome to our ceramics workshop, a space where creativity blends with tradition to shape unique and vibrant pieces!',
      'helloFemale':
          'Hello \$firstName and welcome to our ceramics workshop, a space where creativity blends with tradition to shape unique and vibrant pieces!',
      'helloMale':
          'Hello \$firstName and welcome to our ceramics workshop, a space where creativity blends with tradition to shape unique and vibrant pieces!',
      'whatWeDo': 'What do we do?',
      'workshopDescription':
          'Here, in our workshop, we create everything from small decorative pieces to large works of art, all with a special touch and a unique design.',
      'workshopClasses':
          'We offer classes for all levels, from beginners to experts, where you can learn modeling, glazing, and firing techniques, exploring your own ideas and style.',
      'usersSectionDescription':
          'In this section, you can view registered users, modify their credits, and delete them if necessary.',
      'deleteUser': 'Delete User',
      'confirmDeleteUser': 'Are you sure you want to delete this user?',
      'addCredits': 'Add Credits',
      'selectCreditsToAdd': 'Select how many credits you want to add:',
      'removeCredits': 'Remove Credits',
      'selectCreditsToRemove': 'Select how many credits you want to remove:',
      'noScheduledClasses': '\$fullname has no scheduled classes',
      'scheduledClasses': '\$fullname is attending the classes: \$classes',
      'userDeletedSuccess': 'User deleted successfully',
      'errorAddingCredits': 'Error adding credits',
      'creditsAddedSuccess': 'Credits added successfully',
      'errorRemovingCredits': 'Error removing credits',
      'creditsRemovedSuccess': 'Credits removed successfully',
      'createNewUser': 'Create new user',
      "singleCredit": "credit",
      "multipleCredits": "credits"
    },
    'es': {
      'helloWorld': '¡Hola Mundo!',
      'errorLoadingData': 'Error al cargar los datos',
      'welcomeFemale': '¡Bienvenida al taller de \$taller!',
      'welcomeMale': '¡Bienvenido al taller de \$taller!',
      'helloAnonymous':
          '¡Hola y bienvenido/a a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!',
      'helloFemale':
          '¡Hola \$firstName y bienvenida a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!',
      'helloMale':
          '¡Hola \$firstName y bienvenido a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!',
      'whatWeDo': '¿Qué hacemos?',
      'workshopDescription':
          'Aquí, en nuestro taller, creamos desde pequeñas piezas decorativas hasta grandes obras de arte, todas con un toque especial y un diseño único.',
      'workshopClasses':
          'Ofrecemos clases para todos los niveles, desde principiantes hasta expertos, donde podrás aprender las técnicas de modelado, esmaltado y cocción, explorando tus propias ideas y estilo.',
      'usersSectionDescription':
          'En esta sección podrás ver los usuarios registrados, modificar sus créditos y eliminarlos si es necesario.',
      'deleteUser': 'Eliminar Usuario',
      'confirmDeleteUser': '¿Estás seguro de que deseas eliminar a este usuario?',
      'addCredits': 'Agregar Créditos',
      'selectCreditsToAdd': 'Selecciona cuántos créditos quieres agregar:',
      'removeCredits': 'Remover Créditos',
      'selectCreditsToRemove': 'Selecciona cuántos créditos quieres remover:',
      'noScheduledClasses': '\$fullname no tiene clases programadas',
      'scheduledClasses': '\$fullname asiste a las clases: \$classes',
      'userDeletedSuccess': 'Usuario eliminado exitosamente',
      'errorAddingCredits': 'Error al agregar el crédito',
      'creditsAddedSuccess': 'Crédito agregado exitosamente',
      'errorRemovingCredits': 'Error al remover el crédito',
      'creditsRemovedSuccess': 'Crédito removido exitosamente',
      'createNewUser': 'Crear nuevo usuario',
      "singleCredit": "crédito",
      "multipleCredits": "créditos"
    },
  };

  String translate(String key, {Map<String, String>? params}) {
  String translation = _localizedStrings[locale.languageCode]?[key] ?? key;

  if (params != null) {
    params.forEach((key, value) {
      // Reemplaza las llaves `{}` en lugar de `$`
      translation = translation.replaceAll('{$key}', value);
    });
  }

  return translation;
}

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
