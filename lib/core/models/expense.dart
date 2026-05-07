import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  entertainment,
  health,
  other,
}

class Expense {
  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  factory Expense.create({
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) {
    return Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
  }

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  static const int typeIdValue = 0;

  @override
  int get typeId => typeIdValue;

  @override
  Expense read(BinaryReader reader) {
    final id = reader.readString();
    final amount = reader.readDouble();
    final category = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final note = reader.readString();

    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeString(obj.id)
      ..writeDouble(obj.amount)
      ..writeString(obj.category)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeString(obj.note);
  }
}
