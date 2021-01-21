
import 'package:hive/hive.dart';

part 'todos.g.dart';

@HiveType(typeId: 1)
class Todos extends HiveObject {
  @HiveField(1)
  String title;
  @HiveField(2)
  String detail;
  @HiveField(3)
  bool isSuccess;

  Todos(this.detail, this.title, {this.isSuccess = false});
}
