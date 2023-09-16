import 'package:kuranvenamaz/entity/entity.dart';

class Country implements Entity {
  final String code;
  final String name;

  Country({
    required this.code,
    required this.name,
  });

}