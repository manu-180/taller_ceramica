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
      'singleCredit': '(credit)',
      'multipleCredits': '(credits)',
      'enterNewName': 'Enter your new name:',
      'fullNameLabel': 'Full name',
      'validNameError': 'Please enter a valid name.',
      'nameAlreadyExists': 'This name already exists, please choose another.',
      'nameUpdatedSuccess': 'Name updated successfully.',
      'updateNameButton': 'Update name',
      "storeNotAvailable": "The store is not available.",
      "noProductsAvailable": "No products available.",
      "purchaseError": "Error processing the purchase: \$error",
      "purchaseSuccess": "Purchase completed successfully.",
      "registroSuccess": "Successful registration!",
      "signupScreenIntro":
          "On this screen, you can create users for your students and assign their classes. It is important to do it this way so that, when they log in, they are recognized by the program and automatically redirected to your workshop.",
      "createUserPrompt": "Create your username and password:",
      "emailLabel": "Email Address",
      "passwordLabel": "Password",
      "confirmPasswordLabel": "Confirm Password",
      "invalidEmail": "The email address is invalid.",
      "passwordTooShort": "The password must be at least 6 characters long.",
      "passwordMismatch": "Passwords do not match.",
      "allFieldsRequired": "All fields are required.",
      "emailAlreadyRegistered":
          "The email address is already registered. Please use another one.",
      "fullnameAlreadyExists":
          "The full name already exists. Please use a different name to avoid conflicts.",
      "registrationError": "Registration error: \$error",
      "unexpectedError": "An unexpected error occurred: \$error.",
      "registerButton": "Register",
      "successMessage":
          "Successful registration! Remember to log out before trying to log in again.",
      "confirmCancellation": "Confirm cancellation",
      "cancelWaitlist":
          "Do you want to cancel your spot on the waitlist for the class on \$day at \$time?",
      "cancelClassRefund":
          "Do you want to cancel the class on \$day at \$time? A credit will be generated so you can recover it!",
      "cancelClassNoRefund":
          "Do you want to cancel the class on \$day at \$time? Keep in mind that if you cancel with less than 24 hours in advance, you will not be able to recover the class.",
      "cancelButton": "Cancel",
      "acceptButton": "Accept",
      "classCancelled": "You have canceled your enrollment in the class.",
      "waitlistCancelled": "You have canceled your spot on the waitlist.",
      "loginToViewClasses": "To view your classes, you must log in.",
      "viewCancelClassesInfo":
          "In this section, you can view and cancel your classes. Be careful! If you cancel with less than 24 hours' notice, you will not be able to recover the class.",
      "noClassesEnrolled": "You are not enrolled in any classes.",
      "waitlistPosition": "Your spot on the waitlist is: \$position",
      "workshopTitle": "Ceramics Workshop",
      "homeScreenIntro":
          "If you are an administrator and have not created your account yet, now is the time to start your own workshop!.\nIf you are a student, you must ask the administrator to create your account to get started.",
      "loginPrompt": "Log in :",
      "createWorkshopButton": "Create Workshop",
      "loginError": "Login error: \$error",
      "loginButton": "Log In"
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
      'confirmDeleteUser':
          '¿Estás seguro de que deseas eliminar a este usuario?',
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
      'singleCredit': '(crédito)',
      'multipleCredits': '(créditos)',
      'enterNewName': 'Ingresa tu nuevo nombre:',
      'fullNameLabel': 'Nombre completo',
      'validNameError': 'Por favor, ingresa un nombre válido.',
      'nameAlreadyExists': 'Este nombre ya existe, elige otro.',
      'nameUpdatedSuccess': 'Nombre actualizado con éxito.',
      'updateNameButton': 'Actualizar nombre',
      "storeNotAvailable": "La tienda no está disponible.",
      "noProductsAvailable": "No hay productos disponibles.",
      "purchaseError": "Error al procesar la compra: \$error",
      "purchaseSuccess": "Compra completada con éxito.",
      "registroSuccess": "¡Registro exitoso!",
      "signupScreenIntro":
          "En esta pantalla podés crear usuarios para tus alumnos y asignarles sus clases. Es importante hacerlo de esta manera para que, al iniciar sesión, sean reconocidos por el programa y redirigidos automáticamente a tu taller.",
      "createUserPrompt": "Crea tu usuario y contraseña:",
      "emailLabel": "Correo Electrónico",
      "passwordLabel": "Contraseña",
      "confirmPasswordLabel": "Confirmar Contraseña",
      "invalidEmail": "El correo electrónico es invalido.",
      "passwordTooShort": "La contraseña debe tener al menos 6 caracteres.",
      "passwordMismatch": "La contraseña no coincide.",
      "allFieldsRequired": "Todos los campos son obligatorios.",
      "emailAlreadyRegistered":
          "El correo electrónico ya está registrado. Usa otro.",
      "fullnameAlreadyExists":
          "El nombre completo ya existe. Usa uno diferente para no generar conflictos.",
      "registrationError": "Error de registro: \$error",
      "unexpectedError": "Ocurrió un error inesperado: \$error.",
      "registerButton": "Registrar",
      "successMessage":
          "¡Registro exitoso! Recuerda cerrar sesión antes de intentar iniciar sesión nuevamente.",
      "confirmCancellation": "Confirmar cancelación",
      "cancelWaitlist":
          "¿Deseas cancelar tu lugar en la lista de espera para la clase del día \$day a las \$time?",
      "cancelClassRefund":
          "¿Deseas cancelar la clase el día \$day a las \$time? ¡Se generará un crédito para que puedas recuperarla!",
      "cancelClassNoRefund":
          "¿Deseas cancelar la clase el día \$day a las \$time? Ten en cuenta que si cancelas con menos de 24 horas de anticipación, no podrás recuperar la clase.",
      "cancelButton": "Cancelar",
      "acceptButton": "Aceptar",
      "classCancelled": "Has cancelado tu inscripción en la clase.",
      "waitlistCancelled": "Has cancelado tu lugar en la lista de espera.",
      "loginToViewClasses": "Para ver tus clases debes iniciar sesión.",
      "viewCancelClassesInfo":
          "En esta sección podrás ver y cancelar tus clases. ¡Cuidado! Si cancelas con menos de 24 horas de anticipación, no podrás recuperar la clase.",
      "noClassesEnrolled": "No estás inscripto en ninguna clase.",
      "waitlistPosition": "Tu lugar en la lista de espera es: \$position",
      "workshopTitle": "Taller de Cerámica",
      "homeScreenIntro":
          "Si eres administrador y aún no has creado tu cuenta, ¡es el momento de iniciar tu propio taller!.\nSi eres alumno, deberás solicitar al administrador que cree tu cuenta para comenzar.",
      "loginPrompt": "Inicia sesión :",
      "createWorkshopButton": "Crear Taller",
      "loginError": "Error de inicio de sesión: \$error",
      "loginButton": "Iniciar Sesión"
    }
  };

  String translate(String key, {Map<String, String>? params}) {
    String translation = _localizedStrings[locale.languageCode]?[key] ?? key;

    if (params != null) {
      params.forEach((key, value) {
        translation = translation.replaceAll('\$${key}', value);
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
