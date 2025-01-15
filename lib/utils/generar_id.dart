import 'dart:math';
import 'package:taller_ceramica/models/clase_models.dart';

class GenerarID{

int generarIdUnico(List<ClaseModels> clases) {
  final random = Random();
  Set<int> idsExistentes = clases.map((clase) => clase.id).toSet();

  int nuevoId;
  do {
    nuevoId = random.nextInt(1000000000); 
  } while (idsExistentes.contains(nuevoId));

  return nuevoId;
}

}

